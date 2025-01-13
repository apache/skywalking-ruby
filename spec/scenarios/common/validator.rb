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

module Validator
  def with_retries(retries: 3, backoff_max: 16, backoff_base: 1)
    return if retries < 0

    backoff ||= 0

    yield if block_given?
  rescue SystemExit, Interrupt
    raise
  rescue Exception => e
    p e
    if retries.zero?
      p "Retries exhausted"
      raise e
    else
      retries -= 1
      backoff = [backoff == 0 ? 1 : backoff * 2, backoff_max].min
      backoff *= 0.5 * (1 + Kernel.rand)
      backoff = [backoff_base, backoff].max
      p "Retrying in #{backoff} seconds"

      sleep backoff
      retry
    end
  end
end