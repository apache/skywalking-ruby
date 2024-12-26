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

          @agent = new(config.agent_config).start!
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

      def config
        @config ||= Configuration.new.agent_config
      end
    end

    attr_reader :plugins, :logger, :reporter

    def initialize(config)
      @plugins = Plugins::PluginsManager.new(config)
      @reporter = Reporter::Report.new(config)

      add_shutdown_hook
    end

    def environment
      @environment ||= Skywalking::Environment.instance
    end

    def start!
      @plugins.init_plugins
      @reporter.init_reporter
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
  end
end
