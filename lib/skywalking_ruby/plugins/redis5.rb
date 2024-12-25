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

module SkywalkingRuby
  module Plugins
    class Redis5 < PluginsManager::SWPlugin
      module Redis5Intercept
        def call_v(args, &block)
          operation = args[0] rescue "UNKNOWN"
          return super if operation == :auth

          Tracing::ContextManager.new_exit_span(
            operation: "Redis/#{operation.upcase}",
            peer: _endpoint_info,
            component: Tracing::Component::Redis
          ) do |span|
            span&.tag(Tracing::TagDbType.new("Redis"))
            span&.layer = Tracing.find_mapping(Tracing::Layer, Tracing::Layer::Cache)

            super(args, &block)
          end
        end

        def _endpoint_info
          "#{_redis_cfg.host}:#{_redis_cfg.port}"
        rescue
          "Unknown"
        end

        def _redis_cfg
          @redis_cfg ||= begin
            config = if defined?(::Redis::Client) && is_a?(::Redis::Client)
                       self
                     elsif respond_to?(:client)
                       client&.config
                     elsif defined?(::RedisClient)
                       ::RedisClient.config if ::RedisClient.respond_to?(:config)
                     end
            raise "Redis config not found" unless config
            config
          end
        end
      end

      def plugin_valid?
        version = Gem::Version.new(::Redis::VERSION) rescue nil
        version && version >= Gem::Version.new("5.0.0") && defined?(::Redis) && defined?(::Redis::Client) &&
          ::Redis::Client.instance_methods(false).include?(:call_v)
      end

      def install
        ::Redis::Client.prepend Redis5Intercept
      end

      register :redis5
    end
  end
end
