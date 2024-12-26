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

require_relative 'constants'
require_relative 'carrier'
require_relative '../reporter/client/proto'

module Skywalking
  module Tracing
    class Span
      attr_accessor :operation, :inherit, :component,
        :context, :tags, :peer, :layer

      attr_reader :stack_depth, :kind, :parent_id,
        :start_time, :end_time, :span_id, :refs

      def initialize(
        context:,
        span_id: -1,
        parent_id: -1,
        operation: nil,
        peer: nil,
        kind: nil,
        component: nil,
        layer: nil
      )
        @context = context
        @operation = operation
        @span_id = span_id
        @parent_id = parent_id
        @peer = peer
        @layer = layer || Layer::Unknown
        @kind = kind || nil
        @component = component || Component::Unknown

        @stack_depth = 0
        @inherit = Component::Unknown
        @tags = Hash.new { |hash, key| hash[key] = [] }
        @logs = []
        @refs = []
        @start_time = 0
        @end_time = 0
        @error_occurred = false
      end

      def start
        @stack_depth += 1
        return if @stack_depth != 1

        @start_time = (Process.clock_gettime(Process::CLOCK_REALTIME) * 1000).to_i
        @context.start(self)
      end

      def stop?
        @stack_depth -= 1
        return false unless @stack_depth.zero?

        @context.stop?(self)
      end

      def finish?(segment)
        @end_time = (Process.clock_gettime(Process::CLOCK_REALTIME) * 1000).to_i
        segment.archive(self)

        true
      end

      def tag(tag)
        if tag.insert
          @tags[tag.key] = tag
        else
          @tags[tag.key] << tag
        end
      end

      def tags_item
        @tags.values.map { |tag| KeyStringValuePair.new(key: tag.key, value: tag.val) }
      end

      def inject
        raise 'can only inject context carrier into ExitSpan, this may be a potential bug in the agent, ' \
              'please report this in https://github.com/apache/skywalking/issues if you encounter this. '
      end

      def extract(carrier)
        return self if carrier.nil?

        @context.segment.relate(carrier.trace_id)
        @context.correlation = carrier.correlation_carrier.correlation

        return self unless carrier.valid?

        ref = SegmentRef.new(carrier)
        @refs << ref unless @refs.include?(ref)
        self
      end
    end
  end
end
