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

require_relative 'client/proto'

module Skywalking
  module Reporter
    class BufferTrigger
      include Enumerable

      extend Forwardable
      def_delegators :@buffer, :push

      def initialize(config)
        @config = config
        @max_size = @config[:max_queue_size]
        @buffer = Queue.new
        @mutex = Mutex.new
        @closed = false
      end

      def empty?
        @buffer.empty?
      end

      def <<(segment)
        @mutex.synchronize do
          clear_queue if @buffer.size >= @max_size
          @buffer.push(segment)
        end
      end

      def clear_queue
        @buffer.clear
      end

      def close_queue
        @mutex.synchronize do
          @buffer.close
          @closed = true
        end
      end

      def closed?
        @closed
      end

      def stream_data
        begin
          segment = @buffer.pop(false)
        rescue ThreadError
          return nil
        end

        Enumerator.new do |yie|
          yie << generate_segment(segment) unless segment.nil?
        end
      end

      def generate_segment(segment)
        SegmentObject.new(
          traceId: segment.related_traces[0].to_s,
          traceSegmentId: segment.segment_id.to_s,
          service: @config[:service_name],
          serviceInstance: @config[:instance_name],
          spans: segment.spans.map do |span|
            SpanObject.new(
              spanId: span.span_id,
              parentSpanId: span.parent_id,
              startTime: span.start_time,
              endTime: span.end_time,
              operationName: span.operation,
              peer: span.peer,
              spanType: span.kind,
              spanLayer: span.layer,
              componentId: span.component,
              refs: span.refs.select { |ref| ref.trace_id }.map do |ref|
                SegmentReference.new(
                  refType: ref.ref_type == 'CrossProcess' ? 0 : 1,
                  traceId: ref.trace_id,
                  parentTraceSegmentId: ref.segment_id,
                  parentSpanId: ref.span_id,
                  parentService: ref.service,
                  parentServiceInstance: ref.service_instance,
                  parentEndpoint: ref.endpoint,
                  networkAddressUsedAtPeer: ref.peer
                )
              end,
              tags: span.tags_item
            )
          end
        )
      end
    end
  end
end
