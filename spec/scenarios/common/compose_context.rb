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

RSpec.shared_context 'scenario value' do
  let(:data_validate_url) { 'http://localhost:12800/dataValidate' }
  let(:receive_data_url) { 'http://localhost:12800/receiveData' }
end

RSpec.shared_context 'compose' do
  let(:client_url) { 'http://localhost:8080/execute' }

  let(:compose) do
    Testcontainers::ComposeContainer.new(
      filepath: root_dir,
      compose_filenames: ["docker-compose.yml"]
    )
  end

  before(:each) do
    compose.start
    compose.wait_for_http(url: client_url, timeout: 600)
  end

  after(:each) do
    compose.stop
  end
end