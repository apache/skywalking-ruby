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

require 'base64'
require_relative 'carrier_item'

module Skywalking
  module Tracing
    class Carrier < CarrierItem
      attr_reader :trace_id, :correlation_carrier, :service_instance,
        :endpoint, :segment_id, :span_id,
        :peer, :items, :iter_index

      def initialize(
        trace_id: '',
        segment_id: '',
        span_id: '',
        service: '',
        service_instance: '',
        endpoint: '',
        peer: '',
        correlation: nil
      )
        super(key: 'sw8')

        @trace_id = trace_id
        @segment_id = segment_id
        @span_id = span_id
        @service = service
        @service_instance = service_instance
        @endpoint = endpoint
        @peer = peer
        @correlation_carrier = SW8CorrelationCarrier.new
        @items = [@correlation_carrier, self]
        @iter_index = 0
        @correlation_carrier.correlation = correlation unless correlation.nil?
      end

      def value
        [
          '1',
          Base64.strict_encode64(@trace_id),
          Base64.strict_encode64(@segment_id),
          @span_id,
          Base64.strict_encode64(@service),
          Base64.strict_encode64(@service_instance),
          Base64.strict_encode64(@endpoint),
          Base64.strict_encode64(@peer)
        ].join('-')
      end

      def value=(val)
        @val = val
        return if val.nil? || val.empty?

        parts = val.split('-')
        return if parts.size != 8

        @trace_id = Base64.strict_decode64(parts[1])
        @segment_id = Base64.strict_decode64(parts[2])
        @span_id = parts[3]
        @service = Base64.strict_decode64(parts[4])
        @service_instance = Base64.strict_decode64(parts[5])
        @endpoint = Base64.strict_decode64(parts[6])
        @peer = Base64.strict_decode64(parts[7])
      end

      def valid?
        !@trace_id.empty? && !@segment_id.empty? && !@service.empty? &&
          !@service_instance.empty? && !@endpoint.empty? &&
          !@peer.empty? && @span_id.match?(/^\d+$/)
      end

      def suppressed?
        @val && !valid?
      end

      def each
        @items.each { |item| yield item }
      end
    end

    class SW8CorrelationCarrier < CarrierItem
      attr_accessor :correlation

      def initialize
        super(key: 'sw8-correlation')
        @correlation = {}
      end

      def value
        return '' if @correlation.nil? || @correlation.empty?

        @correlation.map { |k, v| "#{Base64.strict_encode64(k)}:#{Base64.strict_encode64(v)}" }.join(',')
      end

      def value=(val)
        @val = val
        return if val.nil? || val.empty?

        val.split(',').each do |per|
          parts = per.split(':')
          next if parts.size != 2

          @correlation[Base64.strict_decode64(parts[0])] = Base64.strict_decode64(parts[1])
        end
      end
    end
  end
end
