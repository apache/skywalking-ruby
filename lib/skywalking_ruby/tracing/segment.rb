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

require_relative '../utils/id_gen'

module SkywalkingRuby
  module Tracing
    class Segment
      attr_accessor :segment_id, :spans, :timestamp, :related_traces

      def initialize
        @segment_id = Utils::IDGen.new
        @spans = []
        @timestamp = (Process.clock_gettime(Process::CLOCK_REALTIME) * 1000).to_i
        @related_traces = [Utils::IDGen.new]
      end

      def archive(span)
        @spans << span
      end

      def relate(trace_id)
        @related_traces.shift if @related_traces.first.is_a?(Utils::IDGen.new)
        @related_traces << trace_id
      end
    end

    class SegmentRef
      attr_reader :trace_id, :ref_type, :segment_id,
        :span_id, :service, :service_instance,
        :endpoint, :peer

      def initialize(carrier, ref_type: 'CrossProcess')
        @ref_type = ref_type
        @trace_id = carrier.trace_id
        @segment_id = carrier.segment_id
        @span_id = carrier.span_id.to_i
        @service = carrier.service
        @service_instance = carrier.service_instance
        @endpoint = carrier.endpoint
        @peer = carrier.peer
      end
    end
  end
end
