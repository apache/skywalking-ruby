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

require_relative 'configuration'
require_relative 'environment'
require_relative 'plugins_manager'
require_relative 'reporter/report'
require_relative 'reporter/log_buffer_trigger'
require_relative 'tracing/span_context'
require_relative 'tracing/carrier_item'
require_relative 'tracing/segment'
require_relative 'tracing/tag'

module Skywalking
  # @api private
  class Agent
    LOCK = Mutex.new

    class << self
      def agent
        defined?(@agent) && @agent
      end

      def start(config)
        return @agent if @agent

        LOCK.synchronize do
          return @agent if @agent

          config ||= {}
          config = Configuration.new(config) unless config.is_a?(Configuration)

          @logger = config.logger
          @agent_config = config.agent_config
          @agent = new(@agent_config).start!
          config.freeze
        end
      end

      def stop
        LOCK.synchronize do
          return unless @agent

          @agent&.shutdown
          @agent = nil
        end
      end

      def started?
        !!(defined?(@agent) && @agent)
      end

      attr_reader :logger, :agent_config
      
      # Get the singleton instance
      # @return [Agent, nil] the agent instance or nil if not started
      def instance
        @agent
      end
    end

    attr_reader :plugins, :reporter, :log_buffer, :config

    def initialize(config)
      @config = config
      @plugins = Plugins::PluginsManager.new(config)
      @reporter = Reporter::Report.new(config)
      @log_buffer = Reporter::LogBufferTrigger.new(config)

      add_shutdown_hook
    end

    def environment
      @environment ||= Skywalking::Environment.instance
    end

    def start!
      @plugins.init_plugins
      @reporter.init_reporter
      # Start log reporting thread
      start_log_reporting_thread if @config[:log_reporter_active]

      self
    end

    def shutdown
      @reporter.stop
    end

    def add_shutdown_hook
      return unless environment.shutdown_handler_supported?

      at_exit do
        shutdown
      end
    end

    # Check if log reporter is active
    # @return [Boolean] true if log reporter is active
    def log_reporter_active?
      @config[:log_reporter_active]
    end

    private

    # Start the log reporting thread
    def start_log_reporting_thread
      Thread.new do
        loop do
          break unless log_reporter_active?
          
          process_log_queue
          sleep @config[:log_report_period]
        end
      end
    end

    # Process the log queue and send data to the server
    def process_log_queue
      log_count = 0
      Enumerator.new do |yielder|
        while (log_data = log_buffer.stream_data)
          log_data.each do |data| 
            log_count += 1
            yielder << data 
          end
        end
      end.each_slice(10) do |batch|
        begin
          reporter.report_log(batch)
        rescue => e
          Agent.logger.warn "Failed to report log data: #{e.message}"
        end
      end
    end
  end
end
