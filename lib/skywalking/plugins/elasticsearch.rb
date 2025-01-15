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
    class Elasticsearch < PluginsManager::SWPlugin
      def plugin_valid?
        defined?(::Elasticsearch)
      end

      def install
        inst_target = if defined?(::Elastic::Transport::Client)
                        ::Elastic::Transport::Client
                      elsif defined?(::Elasticsearch::Transport::Client)
                        ::Elasticsearch::Transport::Client
                      end

        inst_target.class_eval do
          def perform_request_with_skywalking(method, path, *args, &block)
            peer_info = transport.hosts.first
            db_statement = [{ params: args&.[](0) }]
            unless args[1].nil? || args[1].empty?
              db_statement << { body: args[1] }
            end

            Tracing::ContextManager.new_exit_span(
              operation: "Elasticsearch/#{method}/#{path}",
              peer: "#{peer_info[:protocol]}://#{peer_info[:host]}:#{peer_info[:port]}",
              component: Tracing::Component::Elasticsearch
            ) do |span|
              span&.tag(Tracing::TagDbType.new("Elasticsearch"))
              span&.tag(Tracing::TagDbStatement.new(db_statement))
              span&.layer = Tracing::Layer::Database

              zuper_perform_request(method, path, *args, &block)
            rescue
              span&.error_occurred = true
            end
          end

          alias_method :zuper_perform_request, :perform_request
          alias_method :perform_request, :perform_request_with_skywalking
        end
      end

      register :elasticsearch
    end
  end
end
