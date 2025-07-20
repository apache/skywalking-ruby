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
  module Reporter
    # Manages all reporters in a more elegant way using dependency injection
    class ReporterManager
      include Log::Logging

      attr_reader :reporters, :triggers

      def initialize(config, protocol)
        @config = config
        @protocol = protocol
        @reporters = {}
        @triggers = {}
        @threads = []
        @running = false
      end

      # Register a reporter with its trigger
      # @param name [Symbol] reporter name
      # @param trigger [Object] buffer trigger instance
      # @param report_method [Symbol] method name on protocol to call
      def register_reporter(name, trigger, report_method)
        @triggers[name] = trigger
        @reporters[name] = {
          trigger: trigger,
          report_method: report_method,
          thread: nil
        }
      end

      # Start all registered reporters
      def start
        return if @running
        @running = true

        @reporters.each do |name, reporter|
          thread = Thread.new do
            Thread.current.name = "Reporter-#{name}"
            report_loop(reporter[:trigger], reporter[:report_method])
          end
          reporter[:thread] = thread
          @threads << thread
        end
      end

      # Stop all reporters
      def stop
        @running = false

        @triggers.each_value(&:close_queue)
        @threads.each do |thread|
          thread.join(5) if thread.alive?
        end
        @threads.clear
      end

      # Get trigger by name
      # @param name [Symbol] trigger name
      # @return [Object, nil] trigger instance
      def trigger(name)
        @triggers[name]
      end

      private

      def report_loop(trigger, method_name)
        while @running && !trigger.closed?
          data = trigger.stream_data
          @protocol.send(method_name, data) if data
        end
      rescue => e
        error "Error in reporter loop: #{e.message}"
        error e.backtrace.join("\n")
      end
    end
  end
end
