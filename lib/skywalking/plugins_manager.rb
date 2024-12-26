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
    class PluginsManager
      class << self
        def register(name, plugin_klass)
          installed[name] = plugin_klass
        end

        def installed
          @installed ||= {}
        end
      end

      def initialize(config)
        @config = config
      end

      def init_plugins
        Dir[File.join(__dir__, 'plugins', '*.rb')].each { |file| require file }

        installed_plugins = self.class.installed.keys
        @enabled_plugins ||= installed_plugins - @config[:disable_plugins].split(',')
        @enabled_plugins.each do |plugin_name|
          self.class.installed[plugin_name].try_install(plugin_name)
        end
      end

      class SWPlugin
        include Log::Logging

        def self.register(name, plugin_klass = self)
          Plugins::PluginsManager.register(name, plugin_klass.new)
        end

        def initialize
          @installed = false
        end

        def installed?
          @installed
        end

        def try_install(name)
          info "try to install plugin #{name}"
          unless plugin_valid?
            warn "plugin validation failed for #{name}"
            return
          end
          return if installed?

          begin
            install
            @installed = true
          rescue => e
            error "try to install plugin %s failed, error=%s", name, e.message
          end
        end

        def plugin_valid?
          raise NotImplementedError
        end

        def install
          raise NotImplementedError
        end
      end
    end
  end
end