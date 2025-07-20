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
      # DataSource for collecting thread metrics
      class ThreadDataSource < DataSource
        # Active thread count (alive threads)
        def thread_count_active_generator
          Thread.list.count(&:alive?)
        rescue
          0
        end

        # Running thread count (threads in run state)
        def thread_count_running_generator
          Thread.list.count { |t| t.alive? && t.status == "run" }
        rescue
          0
        end
      end
    end
  end
end
