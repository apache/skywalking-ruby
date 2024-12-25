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

require_relative 'protocol'
require_relative 'client/grpc_client'

module SkywalkingRuby
  module Reporter
    class Grpc < Protocol
      def initialize(config)
        @cfg = config
        @ms_client = SkywalkingRuby::Reporter::Client::GrpcClient::ManagementServiceGrpc.new(config)
        @trace_client = SkywalkingRuby::Reporter::Client::GrpcClient::TraceSegmentReportServiceGrpc.new(config)
        @send_properties_counter = 0
        @counter_mutex = Mutex.new
      end

      def report_heartbeat
        @counter_mutex.synchronize do
          @send_properties_counter += 1
          if (@send_properties_counter.abs % @cfg[:properties_report_period_factor]).zero?
            @ms_client.report_instance_properties
          else
            @ms_client.report_heartbeat
          end
        end
      end

      def report_segment(enumerator)
        @trace_client.report_segment(enumerator)
      end

      def shutdown
        @ms_client.close
        @trace_client.close
      end
    end
  end
end
