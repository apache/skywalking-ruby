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

require 'spec_helper'

module SkywalkingRuby
  RSpec.describe Configuration do
    it 'load DEFAULTS' do
      config = Configuration.new
      expect(config.service_name).to eq 'Your_ApplicationName'
    end
    
    it 'loads args' do
      config = Configuration.new(service_name: 'sw-ruby')
      expect(config.service_name).to eq 'sw-ruby'
    end
    
    it 'loads from yaml' do
      config = Configuration.new(config_file: 'spec/fixtures/agent.yaml')
      expect(config.service_name).to eq 'sw-ruby'
    end
    
    it 'loads from env' do
      ENV['SW_AGENT_SERVICE_NAME'] = 'sw-ruby-env'
      config = Configuration.new
      expect(config.service_name).to eq 'sw-ruby-env'
    end
  end
end