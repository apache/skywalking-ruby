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
      # Enhanced Ruby-specific runtime metrics
      class RubyRuntimeDataSource < DataSource
        def initialize
          @cached_stats = nil
          @cache_time = 0
          @cache_duration = 60
        end

        # Total allocated objects
        def total_allocated_objects_generator
          stats = get_gc_stats
          stats[:total_allocated_objects] || 0
        rescue
          0
        end

        # Heap live slots count - important for memory pressure
        def heap_live_slots_count_generator
          stats = get_gc_stats
          stats[:heap_live_slots] || 0
        rescue
          0
        end

        private

        # Get cached GC statistics, refresh if cache is expired
        def get_gc_stats
          current_time = Time.now.to_i
          if @cached_stats.nil? || (current_time - @cache_time) > @cache_duration
            @cached_stats = GC.stat
            @cache_time = current_time
          end
          @cached_stats
        end
      end
    end
  end
end
