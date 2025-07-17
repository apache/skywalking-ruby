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

require 'singleton'

module Skywalking
  class Environment
    include Singleton
    include Log::Logging

    class RailsFramework
      def name
        :rails
      end

      def present?
        defined?(::Rails) && defined?(::Rails::VERSION)
      end

      def app_name
        if defined?(::Rails)
          ::Rails.application.class.to_s
                 .sub(/::Application$/, '')
        end
      rescue
        nil
      end

      def env
        ::Rails.env
      end
    end

    class SinatraFramework
      def name
        :sinatra
      end

      def present?
        defined?(::Sinatra) && defined?(::Sinatra::Base)
      end

      def app_name
        candidate = ObjectSpace.each_object(Class).select { |klass| klass < ::Sinatra::Base } - [::Sinatra::Application]

        if candidate.length == 1
          candidate.first.name
        else
          "Sinatra"
        end
      rescue
        "Sinatra"
      end

      def env
        ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
      end
    end

    class RubyFramework
      def name
        :ruby
      end

      def present?
        true
      end

      def app_name
        "Ruby"
      end

      def env
        ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
      end
    end

    FRAMEWORKS = [
      RailsFramework.new,
      SinatraFramework.new,
      RubyFramework.new
    ].freeze

    def framework_info
      @framework ||= FRAMEWORKS.detect { |candidate| candidate.present? }
    end

    def framework_name
      @framework_name ||= framework_info.name
    end

    def framework_root
      @framework_root ||= case @framework_name
                          when :rails
                            ::Rails.root
                          when :sinatra
                            Sinatra::Application.root || "."
                          else
                            "."
                          end
    end

    def framework_env
      @framework_env ||= framework_info.env
    end

    def app_name
      framework_info.app_name
    end

    def rails?
      if defined?(::Rails)
        ::Rails.application.class.to_s
               .sub(/::Application$/, '')
      end
    rescue
      nil
    end

    def shutdown_handler_supported?
      case framework_name
      when :sinatra
        warn "Shutdown handler not supported for Sinatra"
        false
      else
        true
      end
    end
  end
end
