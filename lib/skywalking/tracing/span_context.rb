#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require_relative 'span'
require_relative 'entry_span'
require_relative 'exit_span'
require_relative 'carrier'
require_relative '../reporter/report'

module Skywalking
  module Tracing
    class SpanContext
      include Log::Logging

      attr_accessor :segment, :span_id, :correlation, :n_spans, :create_time

      def initialize
        @segment = Tracing::Segment.new
        @span_id = -1
        @correlation = {}
        @n_spans = 0
        @create_time = (Process.clock_gettime(Process::CLOCK_REALTIME) * 1000).to_i
        @primary_endpoint = nil
      end

      def cfg
        @config ||= ::Skywalking::Agent.config
      end

      def ignore_check(operation, carrier: nil)
        if cfg[:re_ignore_operation].match?(operation) || carrier&.suppressed?
          return Tracing::NoopSpan
        end

        nil
      end

      def peek
        spans = ContextManager.spans
        return spans.last unless spans.empty?

        nil
      end

      def new_span(span_klass, parent, **kwargs)
        finished = parent && !parent.stack_depth
        context = finished ? SpanContext.new : self

        span = span_klass.new(
          span_id: context.span_id += 1,
          parent_id: parent && !finished ? parent.span_id : -1,
          context: context,
          **kwargs
        )

        if finished
          carrier = Carrier.new(
            trace_id: parent.context.segment.related_traces[0],
            segment_id: parent.context.segment.segment_id,
            span_id: parent.span_id,
            service: cfg[:service_name],
            service_instance: cfg[:instance_name],
            endpoint: parent.operation,
            peer: parent.peer,
            correlation: parent.context.correlation
          )
          span.extract(carrier)
        end

        span
      end

      def new_entry_span(operation, carrier: nil, inherit: nil)
        span = ignore_check(operation)
        return span if span

        parent = peek
        info 'create new entry span'
        if parent && parent.kind == Kind::Entry && inherit == parent.component
          span = parent
          span.operation = operation
        else
          span = new_span(EntrySpan, parent, operation: operation)
          span.extract(carrier) if carrier&.valid?
        end

        span
      end

      def new_local_span(operation)
        span = ignore_check(operation)
        return span if span

        parent = peek
        info 'create new local span'
        new_span(Span, parent, operation: operation, kind: Kind::Local)
      end

      def new_exit_span(operation, peer, component: nil, inherit: nil)
        span = ignore_check(operation)
        return span if span

        parent = peek
        info 'create new exit span'

        if parent && parent.kind == Kind::Exit && inherit == parent.inherit
          span = parent
          span.operation = operation
          span.peer = peer
          span.component = component
        else
          span = new_span(ExitSpan, parent, operation: operation, peer: peer, component: component)
        end
        span.inherit = inherit if inherit

        span
      end

      def start(span)
        @n_spans += 1
        spans = ContextManager.spans_dup
        unless spans.include?(span)
          spans << span
          if @primary_endpoint.nil?
            @primary_endpoint = PrimaryEndpoint.new(span)
          else
            @primary_endpoint.set_primary_endpoint(span)
          end
        end
      end

      def stop?(span)
        spans = ContextManager.spans_dup
        span.finish?(@segment)
        spans.delete(span)
        @n_spans -= 1
        if @n_spans.zero?
          Reporter::Report.trigger << @segment
          return true
        end

        false
      end

      def active_span
        peek
      end

      class PrimaryEndpoint
        def initialize(span)
          @span = span
        end

        def set_primary_endpoint(span)
          if @span.kind != Kind::Entry && span.kind == Kind::Entry
            @span = span
          end
        end

        def get_name
          @span.operation
        end
      end
    end

    class ContextManager
      class << self
        def spans
          Thread.current[:spans] ||= []
        end

        def spans_dup
          spans_dup = spans.dup
          Thread.current[:spans] = spans_dup

          spans_dup
        end

        def reset_spans
          Thread.current[:spans] = []
        end

        def current_context
          spans_ret = spans
          if spans_ret.any?
            spans.last.context
          else
            SpanContext.new
          end
        end

        def new_exit_span(operation:, peer: nil, component: nil, &block)
          context = current_context
          span = context.new_exit_span(operation, peer, component: component)
          span&.start

          begin
            yield span if block_given?
          ensure
            span&.stop?
          end
        end

        def new_entry_span(operation:, carrier: nil, inherit: nil, &block)
          context = current_context
          span = context.new_entry_span(operation, carrier: carrier, inherit: inherit)
          span&.start

          begin
            yield span if block_given?
          ensure
            span&.stop?
          end
        end

        def new_local_span(operation:, &block)
          context = current_context
          span = context.new_local_span(operation)
          span&.start

          begin
            yield span if block_given?
          ensure
            span&.stop?
          end
        end
      end
    end
  end
end
