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

require 'get_process_mem'
require_relative '../base'

module Skywalking
  module Meter
    module Runtime
      # DataSource for collecting memory usage metrics
      class MemDataSource < DataSource
        def initialize
          @process_mem = GetProcessMem.new
        end

        # Process RSS (Resident Set Size) in MB
        def memory_rss_mb_generator
          @process_mem.bytes / (1024.0 * 1024.0)
        rescue
          0.0
        end

        private

        # Parse /proc/meminfo on Linux or use system commands on macOS
        # @return [Hash] memory info with :total and :available in bytes
        def parse_meminfo
          if RUBY_PLATFORM.include?('linux')
            parse_proc_meminfo
          elsif RUBY_PLATFORM.include?('darwin')
            parse_macos_memory
          else
            { total: 0, available: 0 }
          end
        end

        def parse_proc_meminfo
          meminfo = File.read('/proc/meminfo')
          total = meminfo.match(/MemTotal:\s+(\d+)/)&.captures&.first.to_i * 1024
          available = meminfo.match(/MemAvailable:\s+(\d+)/)&.captures&.first.to_i * 1024
          { total: total, available: available }
        rescue
          { total: 0, available: 0 }
        end

        def parse_macos_memory
          vm_stat = `vm_stat`
          page_size = vm_stat.match(/page size of (\d+) bytes/)&.captures&.first.to_i || 4096
          
          free = vm_stat.match(/Pages free:\s+(\d+)/)&.captures&.first.to_i * page_size
          inactive = vm_stat.match(/Pages inactive:\s+(\d+)/)&.captures&.first.to_i * page_size
          
          total = `sysctl -n hw.memsize`.strip.to_i
          available = free + inactive
          
          { total: total, available: available }
        rescue
          { total: 0, available: 0 }
        end
      end
    end
  end
end
