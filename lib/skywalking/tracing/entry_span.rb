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
    class EntrySpan < Span
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
              operation: operation, peer: peer, kind: Kind::Entry,
              component: component, layer: layer)

        @current_max_depth = 0
      end

      def start
        super

        @current_max_depth = @stack_depth
        @component = Component::Unknown
        @layer = Layer::Unknown
        @lags = []
        @tags = Hash.new { |hash, key| hash[key] = [] }
      end
    end
  end
end
