# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: language-agent/TracingCompat.proto

require 'google/protobuf'

require_relative '../common/Command_pb'
require_relative 'Tracing_pb'


descriptor_data = "\n\"language-agent/TracingCompat.proto\x1a\x14\x63ommon/Command.proto\x1a\x1clanguage-agent/Tracing.proto2\xaf\x01\n\x19TraceSegmentReportService\x12\x44\n\x07\x63ollect\x12\x1c.skywalking.v3.SegmentObject\x1a\x17.skywalking.v3.Commands\"\x00(\x01\x12L\n\rcollectInSync\x12 .skywalking.v3.SegmentCollection\x1a\x17.skywalking.v3.Commands\"\x00\x42\xab\x01\n:org.apache.skywalking.apm.network.language.agent.v3.compatP\x01ZAskywalking.apache.org/repo/goapi/collect/language/agent/v3/compat\xb8\x01\x01\xaa\x02$SkyWalking.NetworkProtocol.V3.Compatb\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

