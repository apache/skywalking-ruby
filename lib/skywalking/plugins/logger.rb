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

require 'logger'

module Skywalking
  module Plugins
    # Logger plugin intercepts Ruby's standard Logger to collect logs
    class Logger < PluginsManager::SWPlugin
      module LoggerIntercept
        # Thread-local flag to prevent recursive log collection
        COLLECTING_LOG_KEY = :skywalking_collecting_log

        # Map Logger severity levels to string names
        SEVERITY_NAMES = {
          ::Logger::DEBUG => 'DEBUG',
          ::Logger::INFO => 'INFO',
          ::Logger::WARN => 'WARN',
          ::Logger::ERROR => 'ERROR',
          ::Logger::FATAL => 'FATAL',
          ::Logger::UNKNOWN => 'UNKNOWN'
        }.freeze

        # Map severity names to levels
        SEVERITY_LEVELS = {
          'DEBUG' => ::Logger::DEBUG,
          'INFO' => ::Logger::INFO,
          'WARN' => ::Logger::WARN,
          'ERROR' => ::Logger::ERROR,
          'FATAL' => ::Logger::FATAL,
          'UNKNOWN' => ::Logger::UNKNOWN
        }.freeze

        # Override the add method to intercept log calls
        # @param severity [Integer] log severity level
        # @param message [String, nil] log message
        # @param progname [String, nil] program name
        # @param block [Proc, nil] block that returns message
        def add(severity, message = nil, progname = nil, &block)
          # Call original method first
          result = super

          # Skip if we're already collecting logs to prevent recursion
          return result if Thread.current[COLLECTING_LOG_KEY]

          # Skip if log reporter is not active
          agent = Agent.instance
          return result unless agent&.log_reporter_active?

          # Check severity threshold
          configured_level = agent.config[:log_reporter_level]
          min_level = if configured_level.is_a?(String)
                        SEVERITY_LEVELS[configured_level.upcase] || ::Logger::INFO
                      else
                        configured_level || ::Logger::INFO
                      end

          return result unless severity >= min_level

          # Set flag to prevent recursion
          Thread.current[COLLECTING_LOG_KEY] = true
          begin
            collect_log_data(severity, message, progname, &block)
          rescue => e
            agent.logger.warn("SkyWalking log collection error: #{e.message}") if agent.config[:debug_mode]
          ensure
            # Always clear the flag
            Thread.current[COLLECTING_LOG_KEY] = false
          end

          result
        end

        private

        # Collect log data and send to SkyWalking
        # @param severity [Integer] log severity level
        # @param message [String, nil] log message
        # @param progname [String, nil] program name
        # @param block [Proc, nil] block that returns message
        def collect_log_data(severity, message, progname, &block)
          # Format the message
          msg = if message.nil?
                  if block_given?
                    yield
                  else
                    progname
                  end
                else
                  message
                end

          return if msg.nil?

          # Get current context
          begin
            context = Tracing::ContextManager.current_context
            trace_context = if context && !context.is_a?(Tracing::IgnoredContext) && context.segment
                              segment = context.segment
                              span = context.active_span

                              V3::TraceContext.new(
                                traceId: segment.related_traces.first&.to_s,
                                traceSegmentId: segment.segment_id.to_s,
                                spanId: span ? span.span_id : -1
                              )
                            end
          rescue
            # If tracing context is not available, continue without it
            trace_context = nil
          end

          # Create log data
          agent = Agent.instance
          return unless agent # Safety check

          log_data = V3::LogData.new(
            timestamp: (Time.now.to_f * 1000).to_i,
            service: agent.config[:service_name],
            serviceInstance: agent.config[:instance_name],
            endpoint: context&.active_span&.operation || '',
            body: V3::LogDataBody.new(
              type: 'text',
              text: V3::TextLog.new(text: msg.to_s)
            ),
            traceContext: trace_context,
            tags: V3::LogTags.new(
              data: [
                V3::KeyStringValuePair.new(key: 'level', value: SEVERITY_NAMES[severity] || 'UNKNOWN'),
                V3::KeyStringValuePair.new(key: 'logger', value: progname || self.class.name),
                V3::KeyStringValuePair.new(key: 'thread', value: Thread.current.name || Thread.current.object_id.to_s)
              ]
            ),
            layer: 'GENERAL'
          )

          # Send to log buffer
          agent.log_buffer << log_data
        end
      end

      # Check if the plugin can be installed
      # @return [Boolean] true if Logger is defined
      def plugin_valid?
        defined?(::Logger)
      end

      # Install the plugin by prepending the intercept module
      def install
        ::Logger.prepend LoggerIntercept
      end

      register :logger
    end
  end
end
