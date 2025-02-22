# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: common/Common.proto

require 'google/protobuf'


descriptor_data = "\n\x13\x63ommon/Common.proto\x12\rskywalking.v3\"0\n\x12KeyStringValuePair\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\r\n\x05value\x18\x02 \x01(\t\"-\n\x0fKeyIntValuePair\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\r\n\x05value\x18\x02 \x01(\x03\"\x1b\n\x03\x43PU\x12\x14\n\x0cusagePercent\x18\x02 \x01(\x01\")\n\x07Instant\x12\x0f\n\x07seconds\x18\x01 \x01(\x03\x12\r\n\x05nanos\x18\x02 \x01(\x05*0\n\x0b\x44\x65tectPoint\x12\n\n\x06\x63lient\x10\x00\x12\n\n\x06server\x10\x01\x12\t\n\x05proxy\x10\x02\x42\x83\x01\n+org.apache.skywalking.apm.network.common.v3P\x01Z2skywalking.apache.org/repo/goapi/collect/common/v3\xaa\x02\x1dSkyWalking.NetworkProtocol.V3b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Skywalking
  module V3
    KeyStringValuePair = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.KeyStringValuePair").msgclass
    KeyIntValuePair = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.KeyIntValuePair").msgclass
    CPU = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.CPU").msgclass
    Instant = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Instant").msgclass
    DetectPoint = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.DetectPoint").enummodule
  end
end
