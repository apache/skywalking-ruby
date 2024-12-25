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

require_relative '../../proto/management/Management_services_pb'
require_relative '../../proto/language-agent/Tracing_services_pb'
require_relative '../../proto/language-agent/Tracing_pb'

module SkywalkingRuby
  ManagementServiceStub = Skywalking::V3::ManagementService::Stub
  InstanceProperties = Skywalking::V3::InstanceProperties
  InstancePingPkg = Skywalking::V3::InstancePingPkg
  TraceSegmentReportServiceStub = Skywalking::V3::TraceSegmentReportService::Stub
  SegmentObject = Skywalking::V3::SegmentObject
  SpanObject = Skywalking::V3::SpanObject
  SegmentReference = Skywalking::V3::SegmentReference
  KeyStringValuePair = Skywalking::V3::KeyStringValuePair
end