# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: management/ManagementCompat.proto

require 'google/protobuf'

require_relative '../common/Command_pb'
require_relative 'Management_pb'


descriptor_data = "\n!management/ManagementCompat.proto\x1a\x14\x63ommon/Command.proto\x1a\x1bmanagement/Management.proto2\xb5\x01\n\x11ManagementService\x12X\n\x18reportInstanceProperties\x12!.skywalking.v3.InstanceProperties\x1a\x17.skywalking.v3.Commands\"\x00\x12\x46\n\tkeepAlive\x12\x1e.skywalking.v3.InstancePingPkg\x1a\x17.skywalking.v3.Commands\"\x00\x42\xa3\x01\n6org.apache.skywalking.apm.network.management.v3.compatP\x01Z=skywalking.apache.org/repo/goapi/collect/management/v3/compat\xb8\x01\x01\xaa\x02$SkyWalking.NetworkProtocol.V3.Compatb\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)
