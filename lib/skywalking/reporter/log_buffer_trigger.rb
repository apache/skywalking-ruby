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

require_relative 'client/proto'

module Skywalking
  module Reporter
    # LogBufferTrigger manages the log data queue and generates protocol messages
    class LogBufferTrigger
      include Enumerable

      extend Forwardable
      def_delegators :@buffer, :push

      # Initialize the log buffer trigger
      # @param config [Hash] configuration options
      def initialize(config)
        @config = config
        @max_size = @config[:max_log_queue_size] || 1000
        @buffer = Queue.new
        @mutex = Mutex.new
        @closed = false
      end

      # Check if the buffer is empty
      # @return [Boolean] true if empty
      def empty?
        @buffer.empty?
      end

      # Add log data to the buffer
      # @param log_data [LogData] the log data to add
      def <<(log_data)
        @mutex.synchronize do
          clear_queue if @buffer.size >= @max_size
          @buffer.push(log_data)
        end
      end

      # Clear the queue
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
      # @return [Boolean] true if closed
      def closed?
        @closed
      end

      # Stream log data from the buffer
      # @return [Enumerator, nil] enumerator of log data or nil if empty
      def stream_data
        begin
          log_data = @buffer.pop(false)
        rescue ThreadError
          return nil
        end

        Enumerator.new do |yielder|
          yielder << log_data unless log_data.nil?
        end
      end
    end
  end
end
