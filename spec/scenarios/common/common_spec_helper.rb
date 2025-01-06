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

require 'testcontainers/compose'
require 'faraday'
require_relative 'validator'

module CommonSpecHelper
  include Validator

  def test_plugin(plugin_name)
    p "Now testing #{plugin_name} plugin"
    expected_data = File.read(File.join(root_dir, 'expected.yml'))

    with_retries do
      resp = Faraday.post(data_validate_url) do |req|
        req.body = expected_data
        req.headers['Content-Type'] = 'application/x-yaml'
      end
      unless resp.status == 200
        actual_data = Faraday.get(receive_data_url).body
        raise "Data validation failed, actual Data: #{actual_data} and cause by: #{resp.body}"
      end
    end
  end
end


