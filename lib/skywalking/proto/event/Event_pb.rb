# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: event/Event.proto

require 'google/protobuf'

require_relative '../common/Command_pb'


descriptor_data = "\n\x11\x65vent/Event.proto\x12\rskywalking.v3\x1a\x14\x63ommon/Command.proto\"\x9e\x02\n\x05\x45vent\x12\x0c\n\x04uuid\x18\x01 \x01(\t\x12%\n\x06source\x18\x02 \x01(\x0b\x32\x15.skywalking.v3.Source\x12\x0c\n\x04name\x18\x03 \x01(\t\x12!\n\x04type\x18\x04 \x01(\x0e\x32\x13.skywalking.v3.Type\x12\x0f\n\x07message\x18\x05 \x01(\t\x12\x38\n\nparameters\x18\x06 \x03(\x0b\x32$.skywalking.v3.Event.ParametersEntry\x12\x11\n\tstartTime\x18\x07 \x01(\x03\x12\x0f\n\x07\x65ndTime\x18\x08 \x01(\x03\x12\r\n\x05layer\x18\t \x01(\t\x1a\x31\n\x0fParametersEntry\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\r\n\x05value\x18\x02 \x01(\t:\x02\x38\x01\"D\n\x06Source\x12\x0f\n\x07service\x18\x01 \x01(\t\x12\x17\n\x0fserviceInstance\x18\x02 \x01(\t\x12\x10\n\x08\x65ndpoint\x18\x03 \x01(\t*\x1d\n\x04Type\x12\n\n\x06Normal\x10\x00\x12\t\n\x05\x45rror\x10\x01\x32L\n\x0c\x45ventService\x12<\n\x07\x63ollect\x12\x14.skywalking.v3.Event\x1a\x17.skywalking.v3.Commands\"\x00(\x01\x42\x81\x01\n*org.apache.skywalking.apm.network.event.v3P\x01Z1skywalking.apache.org/repo/goapi/collect/event/v3\xaa\x02\x1dSkyWalking.NetworkProtocol.V3b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Skywalking
  module V3
    Event = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Event").msgclass
    Source = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Source").msgclass
    Type = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Type").enummodule
  end
end
