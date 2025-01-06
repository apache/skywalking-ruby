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
    class Sinatra < PluginsManager::SWPlugin
      module SinatraIntercept
        def dispatch!(*args, &block)
          req_method = @request.request_method if @request.respond_to?(:request_method)
          carrier = Tracing::Carrier.new
          carrier.each do |item|
            item.val = request.env[item.key.capitalize] if request.env[item.key.capitalize]
          end

          Tracing::ContextManager.new_entry_span(
            operation: "#{req_method}:#{request.env['REQUEST_URI']}",
            carrier: carrier,
            inherit: Tracing::Component::General
          ) do |span|
            span&.tag(Tracing::TagHttpMethod.new(req_method))
            span&.tag(Tracing::TagHttpURL.new(request.env['REQUEST_URI']))
            span&.layer = Tracing::Layer::Http
            span&.peer = "#{request.env['SERVER_NAME']}:#{request.env['SERVER_PORT']}"
            span&.component = Tracing::Component::Sinatra

            super(*args, &block)
          end
        end
      end

      def plugin_valid?
        defined?(::Sinatra::Base) &&
          ::Sinatra::Base.private_method_defined?(:dispatch!)
      end

      def install
        ::Sinatra::Base.prepend SinatraIntercept
      end

      register :sinatra
    end
  end
end
