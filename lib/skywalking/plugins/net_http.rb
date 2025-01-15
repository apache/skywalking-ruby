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
    class NetHttp < PluginsManager::SWPlugin
      module HttpIntercept
        def request(req, body = nil, &block)
          method = req.method
          host = req['host']&.split(':')&.first || address || 'localhost'
          req_path = URI(req.path)
          req_info = ""
          uri = if req_path.host
                  req_path
                else
                  path, query = req.path.split('?')
                  scheme = use_ssl? ? 'https' : 'http'
                  req_info = "#{path}#{query ? "?#{query}" : ''}"
                  full_url = "#{scheme}://#{host}#{":#{port}" if port}#{req_info}"
                  URI(full_url)
                end

          Tracing::ContextManager.new_exit_span(
            operation: "#{method}:#{req_info}",
            peer: host,
            component: Tracing::Component::HttpClient
          ) do |span|
            span&.tag(Tracing::TagHttpMethod.new(method))
            span&.tag(Tracing::TagHttpURL.new(uri))
            span&.layer = Tracing::Layer::Http

            carrier = span&.inject
            headers = req.instance_variable_get(:@header)
            carrier&.each do |item|
              headers[item.key] ||= []
              headers[item.key].concat(Array(item.value))
            end

            result = super(req, body, &block)
            span&.tag(Tracing::TagHttpStatusCode.new(result.code))
            if result.code >= "400"
              span&.error_occurred = true
            end

            result
          end
        end
      end

      def plugin_valid?
        defined?(::Net) && defined?(::Net::HTTP)
      end

      def install
        ::Net::HTTP.prepend HttpIntercept
      end

      register :net_http
    end
  end
end
