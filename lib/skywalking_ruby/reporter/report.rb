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
require_relative 'Scheduler'
require_relative 'buffer_trigger'

module SkywalkingRuby
  module Reporter
    class Report
      def initialize(config)
        @config = config
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
        @daemon_loop = []

        @scheduler_loop = Scheduler.new
        @daemon_loop << Thread.new do
          init_worker_loop
          @scheduler_loop.run
        end

        @@trigger = BufferTrigger.new(@config)
        @daemon_loop << Thread.new do
          report_segment
        end
      end

      def self.trigger
        @@trigger
      end

      def init_worker_loop
        @scheduler_loop.subscribe(:report_heartbeat, @config[:collector_heartbeat_period]) { report_heartbeat }
      end

      def stop
        @scheduler_loop.shutdown
        @@trigger.close_queue
        @daemon_loop.each do |daemon|
          if daemon.alive?
            daemon.wakeup
            daemon.join
          end
        end
      end

      def report_heartbeat
        @protocol.report_heartbeat
      end

      def report_segment
        @protocol.report_segment(@@trigger.stream_data) until @@trigger.closed?
      end
    end
  end
end