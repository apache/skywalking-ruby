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
      # DataSource for collecting GC metrics
      class GcDataSource < DataSource
        # Total GC count
        def gc_count_total_generator
          GC.count
        rescue
          0
        end
        
        # Minor GC count (if available)
        def gc_minor_count_total_generator
          GC.stat[:minor_gc_count] || 0
        rescue
          0
        end
        
        # Major GC count (if available)
        def gc_major_count_total_generator
          GC.stat[:major_gc_count] || 0
        rescue
          0
        end

        # Heap usage percentage
        def heap_usage_percent_generator
          stats = GC.stat
          if stats[:heap_available_slots] && stats[:heap_available_slots] > 0
            (stats[:heap_live_slots].to_f / stats[:heap_available_slots] * 100)
          else
            0.0
          end
        rescue
          0.0
        end
      end
    end
  end
end
