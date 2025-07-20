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
require_relative '../../proto/language-agent/Meter_services_pb'
require_relative '../../proto/language-agent/Meter_pb'
require_relative '../../proto/logging/Logging_services_pb'
require_relative '../../proto/logging/Logging_pb'

module Skywalking
  ManagementServiceStub = Skywalking::V3::ManagementService::Stub
  InstanceProperties = Skywalking::V3::InstanceProperties
  InstancePingPkg = Skywalking::V3::InstancePingPkg
  TraceSegmentReportServiceStub = Skywalking::V3::TraceSegmentReportService::Stub
  SegmentObject = Skywalking::V3::SegmentObject
  SpanObject = Skywalking::V3::SpanObject
  SegmentReference = Skywalking::V3::SegmentReference
  KeyStringValuePair = Skywalking::V3::KeyStringValuePair
  MeterReportServiceStub = Skywalking::V3::MeterReportService::Stub
  MeterData = Skywalking::V3::MeterData
  MeterSingleValue = Skywalking::V3::MeterSingleValue
  MeterHistogram = Skywalking::V3::MeterHistogram
  MeterBucketValue = Skywalking::V3::MeterBucketValue
  Label = Skywalking::V3::Label
end
