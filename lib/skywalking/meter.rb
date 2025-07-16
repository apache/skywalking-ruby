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

require_relative 'meter/base'
require_relative 'meter/meter_service'
require_relative 'meter/runtime/cpu_data_source'
require_relative 'meter/runtime/mem_data_source'
require_relative 'meter/runtime/gc_data_source'
require_relative 'meter/runtime/thread_data_source'

module Skywalking
  # Main module for meter functionality
  module Meter
    # Export key classes for external use
    DataSource = DataSource
    Gauge = Gauge
    MeterService = MeterService
    
    module Runtime
      CpuDataSource = CpuDataSource
      MemDataSource = MemDataSource
      GcDataSource = GcDataSource
      ThreadDataSource = ThreadDataSource
    end
  end
end
