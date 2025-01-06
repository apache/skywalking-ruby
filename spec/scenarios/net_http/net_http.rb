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

require_relative '../../../lib/skywalking'
require 'net/http'
require 'uri'
require 'json'

Skywalking.start

url = URI.parse('http://httpbin.org/json?a=1')

response = Net::HTTP.get_response(url)

if response.is_a?(Net::HTTPSuccess)
  puts JSON.pretty_generate(JSON.parse(response.body))
else
  puts "Error..."
end

sleep 10