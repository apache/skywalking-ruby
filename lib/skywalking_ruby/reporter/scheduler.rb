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
  module Reporter
    class Scheduler
      include Log::Logging

      def initialize
        @read_side, @write_side = IO.pipe
        @queue = Queue.new
        @workers = {}
        @jobs = Hash.new { |h, k| h[k] = [] }
        @jobs[:timer_job] << proc { |worker| add_worker(worker) }
        @jobs[:event_job] << proc { |event, blk| @jobs[event] << blk }
        @running = true
      end

      def run
        while running?
          reads = IO.select([@read_side], nil, nil, find_next_trigger)
          if reads&.dig(0, 0) == @read_side
            @read_side.read(1)
          end
          @workers.each_value do |worker|
            if worker.need_trigger?
              @queue << [worker.job_name]
              worker.set_latest_trigger_time
            end
          end

          until @queue.empty?
            job, args = @queue.pop
            dispatch(job, args)
            @workers[job]&.init_next_trigger_time
          end
        end
      end

      def dispatch(job, args)
        @jobs[job].each do |orig_job|
          begin
            orig_job.call(*args)
          rescue Exception => e
            warn "Error in job #{job}: #{e.message}"
          end
        end
      end

      def subscribe(job_name, job_interval, &job_func)
        trigger(:event_job, [job_name, job_func])
        trigger(:timer_job, Timer.new(job_name, job_interval))
      end

      def trigger(job_type, *args)
        @queue.push([job_type, *args])
        notify
      end

      def find_next_trigger
        return nil if @workers.empty?

        timeout = @workers.values.map(&:next_trigger_time).min - Process.clock_gettime(Process::CLOCK_REALTIME)
        timeout.positive? ? timeout : 0
      end

      def notify
        @write_side.write_nonblock('n')
      end

      def add_worker(worker)
        orig_job = @workers[worker.job_name]
        orig_job.adjust_next_trigger_time(Process.clock_gettime(Process::CLOCK_REALTIME) - orig_job.latest_trigger) if orig_job

        @workers[worker.job_name] = worker
        trigger_worker(worker)
      end

      def trigger_worker(worker)
        if worker.need_trigger?
          @queue.push([worker.job_name])
          worker.set_latest_trigger_time
        end
      end

      def running?
        @running
      end

      def shutdown
        return unless running?

        @running = false
        @write_side.write_nonblock('s')
      end

      class Timer
        attr_reader :job_name, :job_interval, :next_trigger_time, :latest_trigger_time

        def initialize(job_name, job_interval)
          @job_name = job_name
          @job_interval = job_interval
          @start_time = Process.clock_gettime(Process::CLOCK_REALTIME)
          @latest_trigger_time = nil

          init_next_trigger_time
        end

        def init_next_trigger_time
          @next_trigger_time = gen_next_trigger_time
        end

        def set_latest_trigger_time
          @latest_trigger_time = Process.clock_gettime(Process::CLOCK_REALTIME)
        end

        def to_s
          "<Timer job_name: #{@job_name}, job_interval: #{@job_interval}, start_time: #{@start_time}, 
          latest_trigger_time: #{@latest_trigger_time}>"
        end

        def latest_trigger
          @start_time || @latest_trigger_time
        end

        def adjust_next_trigger_time(time)
          @next_trigger_time -= time
        end

        def need_trigger?(now = Process.clock_gettime(Process::CLOCK_REALTIME))
          now >= @next_trigger_time
        end

        def gen_next_trigger_time
          now = Process.clock_gettime(Process::CLOCK_REALTIME)
          return now if @job_interval == 0

          ret = @latest_trigger_time || now
          ret += @job_interval while ret <= now

          ret
        end
      end
    end
  end
end
