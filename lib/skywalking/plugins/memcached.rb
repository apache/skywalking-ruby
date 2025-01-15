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
  module Plugins
    module MemcachedIntercept
      def self.included(klass)
        supported_method =
          [:add, :append, :delete, :cas, :incr, :increment, :prepend, :replace, :set, :get, :fetch]
          .select do |method_name|
            klass.method_defined?(method_name) || klass.private_method_defined?(method_name)
          end

        supported_method.each do |method_name|
          zuper_method = :"zuper_#{method_name}"
          method_with_skywalking = :"#{method_name}_with_skywalking"

          klass.class_eval do
            define_method(method_with_skywalking) do |*args, &block|
              cache_key = args[0].to_s if args.length && !args[0].is_a?(Array)
              Tracing::ContextManager.new_exit_span(
                operation: "Memcached/#{method_name}",
                peer: @normalized_servers.join(','),
                component: Tracing::Component::Memcached
              ) do |span|
                span&.layer = Tracing::Layer::Cache
                span&.tag(Tracing::TagCacheType.new("Memcached"))
                span&.tag(Tracing::TagCacheKey.new(cache_key))

                resp = __send__(zuper_method, *args, &block)
                if method_name == :get && args.length && args[0].instance_of?(String)
                  span&.tag(Tracing::TagCacheMiss.new(resp.nil?))
                end

                resp
              rescue
                span&.error_occurred = true
              end
            end

            alias_method zuper_method, method_name
            alias_method method_name, method_with_skywalking
          end
        end
      end
    end

    class Memcached < PluginsManager::SWPlugin
      def plugin_valid?
        defined?(::Dalli::Client)
      end

      def install
        ::Dalli::Client.class_eval do
          include Skywalking::Plugins::MemcachedIntercept
        end
      end

      register :memcached
    end
  end
end
