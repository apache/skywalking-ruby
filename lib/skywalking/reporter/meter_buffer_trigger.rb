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

require 'forwardable'

module Skywalking
  module Reporter
    # Buffer trigger for meter data collection
    class MeterBufferTrigger
      include Enumerable

      extend Forwardable
      def_delegators :@buffer, :push

      # @param config [Hash] configuration
      def initialize(config)
        @config = config
        @max_size = @config[:max_meter_queue_size] || 1000
        @buffer = Queue.new
        @mutex = Mutex.new
        @closed = false
      end

      # Check if buffer is empty
      # @return [Boolean]
      def empty?
        @buffer.empty?
      end

      # Add meter data to buffer
      # @param meter_data [MeterData] the meter data to add
      def <<(meter_data)
        @mutex.synchronize do
          clear_queue if @buffer.size >= @max_size
          @buffer.push(meter_data)
        end
      end

      # Clear all data from the queue
      def clear_queue
        @buffer.clear
      end

      # Close the queue
      def close_queue
        @mutex.synchronize do
          @buffer.close
          @closed = true
        end
      end

      # Check if the queue is closed
      # @return [Boolean]
      def closed?
        @closed
      end

      # Stream meter data from the buffer
      # @return [Enumerator, nil]
      def stream_data
        data_batch = []

        # Collect up to 100 items or until timeout
        deadline = Time.now + 0.1
        while Time.now < deadline && data_batch.size < 100
          begin
            meter_data = @buffer.pop(true)
            data_batch << meter_data
          rescue ThreadError
            break
          end
        end

        return nil if data_batch.empty?

        Enumerator.new do |yielder|
          data_batch.each { |data| yielder << data }
        end
      end
    end
  end
end
