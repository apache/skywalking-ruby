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

module Skywalking
  module Meter
    # Service to manage metric collection and reporting
    class MeterService
      include Log::Logging

      # @param config [Hash] configuration
      # @param meter_trigger [MeterBufferTrigger] buffer trigger for queuing data
      def initialize(config, meter_trigger)
        @config = config
        @gauges = []
        @meter_trigger = meter_trigger
        @running = false
        @mutex = Mutex.new
        @collector_thread = nil
      end

      # Register a gauge for collection
      # @param gauge [Gauge] the gauge to register
      def register(gauge)
        @mutex.synchronize do
          @gauges << gauge
        end
      end

      # Start the meter collection service
      def start
        return if @running

        @running = true

        @collector_thread = Thread.new do
          Thread.current.name = 'MeterCollector'
          run_collection_loop
        end
      end

      # Stop the meter collection service
      def stop
        return unless @running

        @running = false
        @collector_thread&.join(5)
      end

      private

      def run_collection_loop
        period = @config[:meter_report_period] || 20
        
        while @running
          begin
            collect_and_queue_metrics
            sleep period
          rescue => e
            error "Error in meter collection loop: #{e.message}"
            error e.backtrace.join("\n")
            sleep period
          end
        end
      end

      def collect_and_queue_metrics
        @mutex.synchronize do
          collected_count = 0
          @gauges.each do |gauge|
            begin
              meter_data = gauge.collect
              if meter_data
                meter_data.service = @config[:service_name]
                meter_data.serviceInstance = @config[:instance_name]
                meter_data.timestamp = (Time.now.to_f * 1000).to_i
                @meter_trigger << meter_data
                collected_count += 1
              end
            rescue => e
              warn "Error collecting gauge #{gauge.name}: #{e.message}"
            end
          end
        end
      end
    end
  end
end
