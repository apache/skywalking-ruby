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
          @cached_total_memory = nil
          @cache_time = 0
          @cache_duration = 60
          @ffi_loaded = false
          load_ffi_if_available
        end

        # Process RSS (Resident Set Size) in MB
        def memory_rss_mb_generator
          @process_mem.bytes / (1024.0 * 1024.0)
        rescue
          0.0
        end

        # Process memory usage percentage
        def memory_usage_percent_generator
          rss_bytes = @process_mem.bytes
          total_memory = get_total_memory

          if total_memory && total_memory > 0
            (rss_bytes.to_f / total_memory * 100).round(2)
          end
        rescue
          nil
        end

        private

        # Load FFI if available for more efficient system calls
        def load_ffi_if_available
          require 'ffi'
          @ffi_loaded = true
        rescue LoadError
          @ffi_loaded = false
        end

        # Get total system memory with caching to avoid frequent system calls
        def get_total_memory
          current_time = Time.now.to_i

          if @cached_total_memory.nil? || (current_time - @cache_time) > @cache_duration
            @cached_total_memory = fetch_total_memory
            @cache_time = current_time
          end

          @cached_total_memory
        end

        # Fetch total memory using platform-specific methods
        def fetch_total_memory
          if RUBY_PLATFORM.include?('linux')
            fetch_linux_total_memory
          elsif RUBY_PLATFORM.include?('darwin')
            fetch_macos_total_memory
          end
        end

        # Fetch total memory on Linux using /proc/meminfo
        def fetch_linux_total_memory
          meminfo = File.read('/proc/meminfo')
          total = (meminfo.match(/MemTotal:\s+(\d+)/)&.captures&.first || '0').to_i * 1024
          total > 0 ? total : nil
        rescue
          nil
        end

        # Fetch total memory on macOS using sysctl
        def fetch_macos_total_memory
          if @ffi_loaded
            result = fetch_macos_total_memory_ffi
            return result if result
          end

          fetch_macos_total_memory_sysctl
        end

        # Use FFI to call sysctl directly
        def fetch_macos_total_memory_ffi
          extend FFI::Library
          ffi_lib 'c'

          attach_function :sysctl, [:pointer, :uint, :pointer, :pointer, :pointer, :size_t], :int

          # sysctlnametomib for hw.memsize
          mib = FFI::MemoryPointer.new(:int, 2)
          mib.put_int(0, 6) # CTL_HW
          mib.put_int(4, 24) # HW_MEMSIZE

          size = FFI::MemoryPointer.new(:size_t)
          size.put_size_t(0, 8)

          result = FFI::MemoryPointer.new(:uint64_t)

          if sysctl(mib, 2, result, size, nil, 0) == 0
            value = result.read_uint64
            value > 0 ? value : nil
          end
        rescue
          nil
        end

        # Fallback to sysctl command (still forks but cached)
        def fetch_macos_total_memory_sysctl
          result = `sysctl -n hw.memsize 2>/dev/null`.strip.to_i
          result > 0 ? result : nil
        rescue
          nil
        end
      end
    end
  end
end
