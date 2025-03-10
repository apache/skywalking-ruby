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

require_relative '../common/common_spec_helper'
require_relative '../common/compose_context'

RSpec.describe 'NetHttp' do
  include CommonSpecHelper
  include_context 'scenario value'

  let(:root_dir) { File.expand_path(__dir__) }

  let(:compose) do
    Testcontainers::ComposeContainer.new(
      filepath: root_dir,
      compose_filenames: ["docker-compose.yml"]
    )
  end

  before(:each) do
    compose.start
  end

  after(:each) do
    compose.stop
  end

  it 'test the net_http plugin' do
    test_plugin('net_http')
  end
end
