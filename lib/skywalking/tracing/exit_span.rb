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

module Skywalking
  module Tracing
    class ExitSpan < Span
      def initialize(
        context:,
        span_id: -1,
        parent_id: -1,
        operation: nil,
        peer: nil,
        component: nil,
        layer: nil
      )
        super(context: context, span_id: span_id, parent_id: parent_id,
              operation: operation, peer: peer, kind: Kind::Exit,
              component: component, layer: layer)
      end

      def cfg
        @config ||= ::Skywalking::Agent.agent_config
      end

      def inject
        Carrier.new(
          trace_id: @context.segment.related_traces[0].to_s,
          segment_id: @context.segment.segment_id.to_s,
          span_id: @span_id.to_s,
          service: cfg[:service_name],
          service_instance: cfg[:instance_name],
          endpoint: @operation,
          peer: @peer,
          correlation: @context.correlation
        )
      end
    end
  end
end
