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

module SkywalkingRuby
  module Tracing
    module Component
      Unknown = 0
      Redis = 7
      General = 12000
      Sinatra = 12001
    end

    module Layer
      Unknown = 0
      Database = 1
      RPCFramework = 2
      Http = 3
      MQ = 4
      Cache = 5
      FAAS = 6
    end

    module Kind
      Local = 0
      Entry = 1
      Exit = 2
    end

    def self.find_mapping(category, value)
      category.constants.each do |const_name|
        return const_name if category.const_get(const_name) == value
      end

      'Unknown'
    end
  end
end
