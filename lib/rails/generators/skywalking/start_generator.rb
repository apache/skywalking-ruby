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
  class StartGenerator < ::Rails::Generators::Base
    source_root File.join(File.dirname(__FILE__), 'templates')
    desc 'Creates a skywalking initializer'

    @namespace = "skywalking:start"

    def copy_initializer
      print_header
      print_footer

      template "skywalking_initializer.rb", "config/initializers/skywalking.rb"
    end

    private

    def print_header
      say ""
      say shell.set_color "Welcome to the SkyWalking Ruby Agent instrumentation setup.", :green, :bold
      say ""
    end

    def print_footer
      say ""
      say "You can configure skywalking start parameters by modifying config/initializers/skywalking.rb."
      say ""
      say "Thanks for using! Welcome to contribute to the SkyWalking community."
      say ""
    end
  end
end

