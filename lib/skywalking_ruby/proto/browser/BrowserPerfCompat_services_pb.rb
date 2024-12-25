# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: browser/BrowserPerfCompat.proto for package ''
# Original file comments:
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

require 'grpc'
require_relative 'BrowserPerfCompat_pb'

module BrowserPerfService
  # Collect performance raw data from browser.
  class Service

    include ::GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'BrowserPerfService'

    # report once per page
    rpc :collectPerfData, ::Skywalking::V3::BrowserPerfData, ::Skywalking::V3::Commands
    # report one or more error logs for pages, could report multiple times.
    rpc :collectErrorLogs, stream(::Skywalking::V3::BrowserErrorLog), ::Skywalking::V3::Commands
  end

  Stub = Service.rpc_stub_class
end