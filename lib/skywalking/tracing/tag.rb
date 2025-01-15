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
    class Tag
      attr_accessor :val
      attr_reader :key, :insert

      def initialize(val)
        @val = val.to_s
        @insert = true
      end
    end

    class TagHttpMethod < Tag
      def initialize(val)
        super
        @key = 'http.method'
      end
    end

    class TagHttpURL < Tag
      def initialize(val)
        super
        @key = 'http.url'
      end
    end

    class TagHttpStatusCode < Tag
      def initialize(val)
        super
        @key = 'http.status_code'
      end
    end

    class TagDbType < Tag
      def initialize(val)
        super
        @key = 'db.type'
      end
    end

    class TagDbStatement < Tag
      def initialize(val)
        super
        @key = 'db.statement'
      end
    end

    class TagCacheType < Tag
      def initialize(val)
        super
        @key = 'cache.type'
      end
    end

    class TagCacheOp < Tag
      def initialize(val)
        super
        @key = 'cache.op'
      end
    end

    class TagCacheCmd < Tag
      def initialize(val)
        super
        @key = 'cache.cmd'
      end
    end

    class TagCacheKey < Tag
      def initialize(val)
        super
        @key = 'cache.key'
      end
    end

    class TagCacheMiss < Tag
      def initialize(val)
        super
        @key = 'cache.miss'
      end
    end
  end
end
