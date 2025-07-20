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

require_relative 'proto'
require_relative '../../tracing/constants'

module Skywalking
  module Reporter
    module Client
      class GrpcClient
        class ManagementServiceGrpc
          include Log::Logging

          def initialize(config)
            @config = config
            @management_service ||= ManagementServiceStub.new(
              @config[:collector_backend_services],
              :this_channel_is_insecure
            )
          end

          def report_instance_properties
            begin
              properties = gen_service_instance
              req = InstanceProperties.new(
                service: @config[:service_name],
                serviceInstance: @config[:instance_name],
                properties: properties
              )

              @management_service.report_instance_properties(req)
            rescue Exception => e
              error "Error to report instance properties: #{e.message}"
            end
          end

          def report_heartbeat
            begin
              req = InstancePingPkg.new(
                service: @config[:service_name],
                serviceInstance: @config[:instance_name]
              )

              @management_service.keep_alive(req)
            rescue => e
              error "Error to connect SkyWalking APM: #{e.message}"
            end
          end

          def gen_service_instance
            props = []

            begin
              props.push(
                { key: 'language', value: 'ruby' },
                { key: 'OS Name', value: RbConfig::CONFIG['host_os'] },
                { key: 'Process No.', value: Process.pid.to_s },
                { key: 'hostname', value: Socket.gethostname },
                { key: 'ipv4', value: Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).join('; ') },
                { key: 'ruby_engine', value: RUBY_ENGINE },
                { key: 'ruby_version', value: RUBY_VERSION }
              )
            rescue => e
              warn "Failed to get local environment information: #{e.message}"
              props = [{ key: 'language', value: 'ruby' }, { key: 'Process No.', value: Process.pid.to_s }]
            end

            namespace = @config[:namespace]
            props << { key: 'namespace', value: namespace } if namespace

            instance_properties_json = @config[:instance_properties_json]
            if instance_properties_json && !instance_properties_json.empty?
              json_properties = JSON.parse(instance_properties_json)
              json_properties.each do |key, value|
                props << { key: key, value: value }
              end
            end

            props
          end
        end

        class TraceSegmentReportServiceGrpc
          include Log::Logging

          def initialize(config)
            @config = config
            @trace_service ||= TraceSegmentReportServiceStub.new(
              @config[:collector_backend_services],
              :this_channel_is_insecure
            )
          end

          def report_segment(enumerator)
            @trace_service.collect(enumerator)
          rescue Exception => e
            error "Error to report trace segment: #{e.message}}"
          end
        end

        class MeterReportServiceGrpc
          include Log::Logging

          def initialize(config)
            @config = config
            @meter_service ||= MeterReportServiceStub.new(
              @config[:collector_backend_services],
              :this_channel_is_insecure
            )
          end

          def report_meter(enumerator)
            @meter_service.collect(enumerator)
          rescue Exception => e
            error "Error to report meter data: #{e.message}"
          end
        end

        class LogReportServiceGrpc
          include Log::Logging

          def initialize(config)
            @config = config
            @log_service ||= V3::LogReportService::Stub.new(
              @config[:collector_backend_services],
              :this_channel_is_insecure
            )
          end

          def report_log(log_data_array)
            return if log_data_array.nil? || log_data_array.empty?

            # Create an enumerator that yields log data
            enumerator = Enumerator.new do |yielder|
              log_data_array.each { |log_data| yielder << log_data }
            end

            @log_service.collect(enumerator)
          rescue Exception => e
            error "Error to report log data: #{e.message}"
          end
        end
      end
    end
  end
end