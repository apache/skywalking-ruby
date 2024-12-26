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

    def framework_info
      @framework_info ||= generate_framework_info
    end

    def generate_framework_info
      if defined?(::Rails::Application)
        :rails
      elsif defined?(::Sinatra::Base)
        :sinatra
      else
        :ruby
      end
    end
    
    def sinatra?
      @framework_info = :sinatra
    end

    def shutdown_handler_supported?
      if sinatra?
        info "Shutdown handler not supported for Sinatra"
        false
      else
        true
      end
    end
  end
end
