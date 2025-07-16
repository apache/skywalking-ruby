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

require 'sys/cpu'
require_relative '../base'

module Skywalking
  module Meter
    module Runtime
      # DataSource for collecting CPU usage metrics
      class CpuDataSource < DataSource
        def initialize
          @cpu_count = Sys::CPU.num_cpu || 1
        end
        
        # Return current process CPU utilization percentage
        def cpu_usage_percent_generator
          # Use Sys::CPU load average as a simple metric
          # This is similar to how Python's psutil works
          load_avg = Sys::CPU.load_avg[0] # 1-minute load average
          load_avg * 100.0 / @cpu_count
          
        rescue
          0.0
        end
      end
    end
  end
end
