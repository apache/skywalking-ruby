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

require_relative '../reporter/client/proto'

module Skywalking
  module Meter
    # Base class for all data sources
    class DataSource
      # Automatically register all generator methods as gauges
      # @param meter_service [MeterService] the service to register gauges with
      def register(meter_service)
        methods.grep(/_generator$/).each do |method_name|
          metric_name = "instance_ruby_#{method_name.to_s.sub('_generator', '')}"
          # Create a lambda that calls the generator method
          getter = lambda { send(method_name) }
          gauge = Gauge.new(metric_name, getter)
          meter_service.register(gauge)
        end
      end
    end

    # Represents a gauge metric that reports instantaneous values
    class Gauge
      attr_reader :name

      # @param name [String] metric name
      # @param getter [Proc] a callable that returns the current value
      def initialize(name, getter)
        @name = name
        @getter = getter
        @labels = []
      end

      # Add a label to this gauge
      # @param key [String] label key
      # @param value [String] label value
      # @return [self]
      def add_label(key, value)
        @labels << Label.new(name: key, value: value)
        self
      end

      # Collect current metric value
      # @return [MeterData] meter data
      def collect
        value = @getter.call
        MeterData.new(
          singleValue: MeterSingleValue.new(
            name: @name,
            value: value.to_f,
            labels: @labels
          )
        )
      rescue
        # Return zero value if getter fails
        MeterData.new(
          singleValue: MeterSingleValue.new(
            name: @name,
            value: 0.0,
            labels: @labels
          )
        )
      end
    end
  end
end
