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

require_relative '../base'

module Skywalking
  module Meter
    module Runtime
      # DataSource for collecting Ruby process CPU usage metrics
      class CpuDataSource < DataSource
        def initialize
          @last_cpu_time = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
          @last_wall_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        # Ruby process CPU usage percentage
        def cpu_usage_percent_generator
          begin
            current_cpu_time = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
            current_wall_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            cpu_time_diff = current_cpu_time - @last_cpu_time
            wall_time_diff = current_wall_time - @last_wall_time

            # Calculate CPU usage as percentage of wall time
            if wall_time_diff > 0
              cpu_usage = (cpu_time_diff / wall_time_diff) * 100.0
              cpu_usage = [cpu_usage, 0.0].max
            else
              cpu_usage = 0.0
            end

            # Update last values for next calculation
            @last_cpu_time = current_cpu_time
            @last_wall_time = current_wall_time

            cpu_usage
          rescue
            0.0
          end
        end
      end
    end
  end
end
