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

module Skywalking
  module Tracing
    module Component
      Unknown = 0
      HttpClient = 2
      Redis = 7
      Memcached = 20
      Elasticsearch = 47
      General = 12000
      Sinatra = 12001
    end

    module Layer
      Unknown = "Unknown".freeze
      Database = "Database".freeze
      RPCFramework = "RPCFramework".freeze
      Http = "Http".freeze
      MQ = "MQ".freeze
      Cache = "Cache".freeze
      FAAS = "FAAS".freeze
    end

    module Kind
      Local = "Local".freeze
      Entry = "Entry".freeze
      Exit = "Exit".freeze
    end
  end
end
