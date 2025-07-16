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

require_relative 'grpc'
require_relative 'scheduler'
require_relative 'buffer_trigger'
require_relative 'meter_buffer_trigger'
require_relative 'reporter_manager'
require_relative '../meter/base'
require_relative '../meter/meter_service'
require_relative '../meter/runtime/cpu_data_source'
require_relative '../meter/runtime/mem_data_source'
require_relative '../meter/runtime/gc_data_source'
require_relative '../meter/runtime/thread_data_source'
require_relative '../meter/runtime/ruby_runtime_data_source'

module Skywalking
  module Reporter
    class Report
      def initialize(config)
        @config = config
        @meter_service = nil
        @scheduler_loop = nil
        @reporter_manager = nil
        init_proto
      end

      def init_proto
        return if @protocol

        case @config[:report_protocol]
        when 'grpc'
          @protocol = Grpc.new(@config)
        else
          raise "Unsupported report protocol: #{@config[:report_protocol]}"
        end
      end

      def init_reporter
        # Initialize scheduler for heartbeat
        @scheduler_loop = Scheduler.new
        @scheduler_thread = Thread.new do
          Thread.current.name = 'Scheduler'
          init_worker_loop
          @scheduler_loop.run
        end

        # Initialize reporter manager
        @reporter_manager = ReporterManager.new(@config, @protocol)
        
        # Register segment reporter
        segment_trigger = BufferTrigger.new(@config)
        @reporter_manager.register_reporter(:segment, segment_trigger, :report_segment)
        
        # Register meter reporter if enabled
        if @config[:meter_reporter_active]
          meter_trigger = MeterBufferTrigger.new(@config)
          @reporter_manager.register_reporter(:meter, meter_trigger, :report_meter)
          
          # Initialize meter service
          @meter_service = Skywalking::Meter::MeterService.new(@config, meter_trigger)
          
          if @config[:runtime_meter_reporter_active]
            register_runtime_data_sources
          end
          
          @meter_service.start
        end
        
        # Start all reporters
        @reporter_manager.start
      end

      # Deprecated: Use instance method instead
      def self.trigger
        warn "[DEPRECATED] Report.trigger is deprecated. Use instance method 'trigger' instead."
        nil
      end

      def init_worker_loop
        @scheduler_loop.subscribe(:report_heartbeat, @config[:collector_heartbeat_period]) { report_heartbeat }
      end

      def stop
        @scheduler_loop&.shutdown
        @scheduler_thread&.join(5)
        @reporter_manager&.stop
        @meter_service&.stop
      end

      def report_heartbeat
        @protocol.report_heartbeat
      end
      
      # Accessor methods for triggers
      def trigger
        @reporter_manager&.trigger(:segment)
      end
      
      def meter_trigger
        @reporter_manager&.trigger(:meter)
      end
      
      # Report log data to the backend
      # @param log_data_array [Array<LogData>] array of log data to report
      def report_log(log_data_array)
        @protocol.report_log(log_data_array) if @protocol
      rescue => e
        warn "Failed to report log data: #{e.message}"
      end
      
      private
      
      def register_runtime_data_sources
        Skywalking::Meter::Runtime::CpuDataSource.new.register(@meter_service)
        Skywalking::Meter::Runtime::MemDataSource.new.register(@meter_service)
        Skywalking::Meter::Runtime::GcDataSource.new.register(@meter_service)
        Skywalking::Meter::Runtime::ThreadDataSource.new.register(@meter_service)
        Skywalking::Meter::Runtime::RubyRuntimeDataSource.new.register(@meter_service)
      end
    end
  end
end
