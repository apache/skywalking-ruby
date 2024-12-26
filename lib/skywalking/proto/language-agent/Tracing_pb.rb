# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: language-agent/Tracing.proto

require 'google/protobuf'

require_relative '../common/Common_pb'
require_relative '../common/Command_pb'


descriptor_data = "\n\x1clanguage-agent/Tracing.proto\x12\rskywalking.v3\x1a\x13\x63ommon/Common.proto\x1a\x14\x63ommon/Command.proto\"\xa3\x01\n\rSegmentObject\x12\x0f\n\x07traceId\x18\x01 \x01(\t\x12\x16\n\x0etraceSegmentId\x18\x02 \x01(\t\x12(\n\x05spans\x18\x03 \x03(\x0b\x32\x19.skywalking.v3.SpanObject\x12\x0f\n\x07service\x18\x04 \x01(\t\x12\x17\n\x0fserviceInstance\x18\x05 \x01(\t\x12\x15\n\risSizeLimited\x18\x06 \x01(\x08\"\xf0\x01\n\x10SegmentReference\x12\'\n\x07refType\x18\x01 \x01(\x0e\x32\x16.skywalking.v3.RefType\x12\x0f\n\x07traceId\x18\x02 \x01(\t\x12\x1c\n\x14parentTraceSegmentId\x18\x03 \x01(\t\x12\x14\n\x0cparentSpanId\x18\x04 \x01(\x05\x12\x15\n\rparentService\x18\x05 \x01(\t\x12\x1d\n\x15parentServiceInstance\x18\x06 \x01(\t\x12\x16\n\x0eparentEndpoint\x18\x07 \x01(\t\x12 \n\x18networkAddressUsedAtPeer\x18\x08 \x01(\t\"\x91\x03\n\nSpanObject\x12\x0e\n\x06spanId\x18\x01 \x01(\x05\x12\x14\n\x0cparentSpanId\x18\x02 \x01(\x05\x12\x11\n\tstartTime\x18\x03 \x01(\x03\x12\x0f\n\x07\x65ndTime\x18\x04 \x01(\x03\x12-\n\x04refs\x18\x05 \x03(\x0b\x32\x1f.skywalking.v3.SegmentReference\x12\x15\n\roperationName\x18\x06 \x01(\t\x12\x0c\n\x04peer\x18\x07 \x01(\t\x12)\n\x08spanType\x18\x08 \x01(\x0e\x32\x17.skywalking.v3.SpanType\x12+\n\tspanLayer\x18\t \x01(\x0e\x32\x18.skywalking.v3.SpanLayer\x12\x13\n\x0b\x63omponentId\x18\n \x01(\x05\x12\x0f\n\x07isError\x18\x0b \x01(\x08\x12/\n\x04tags\x18\x0c \x03(\x0b\x32!.skywalking.v3.KeyStringValuePair\x12 \n\x04logs\x18\r \x03(\x0b\x32\x12.skywalking.v3.Log\x12\x14\n\x0cskipAnalysis\x18\x0e \x01(\x08\"D\n\x03Log\x12\x0c\n\x04time\x18\x01 \x01(\x03\x12/\n\x04\x64\x61ta\x18\x02 \x03(\x0b\x32!.skywalking.v3.KeyStringValuePair\"\x10\n\x02ID\x12\n\n\x02id\x18\x01 \x03(\t\"C\n\x11SegmentCollection\x12.\n\x08segments\x18\x01 \x03(\x0b\x32\x1c.skywalking.v3.SegmentObject\"\xdc\x03\n\x11SpanAttachedEvent\x12)\n\tstartTime\x18\x01 \x01(\x0b\x32\x16.skywalking.v3.Instant\x12\r\n\x05\x65vent\x18\x02 \x01(\t\x12\'\n\x07\x65ndTime\x18\x03 \x01(\x0b\x32\x16.skywalking.v3.Instant\x12/\n\x04tags\x18\x04 \x03(\x0b\x32!.skywalking.v3.KeyStringValuePair\x12/\n\x07summary\x18\x05 \x03(\x0b\x32\x1e.skywalking.v3.KeyIntValuePair\x12\x44\n\x0ctraceContext\x18\x06 \x01(\x0b\x32..skywalking.v3.SpanAttachedEvent.SpanReference\x1a\x8a\x01\n\rSpanReference\x12@\n\x04type\x18\x01 \x01(\x0e\x32\x32.skywalking.v3.SpanAttachedEvent.SpanReferenceType\x12\x0f\n\x07traceId\x18\x02 \x01(\t\x12\x16\n\x0etraceSegmentId\x18\x03 \x01(\t\x12\x0e\n\x06spanId\x18\x04 \x01(\t\"/\n\x11SpanReferenceType\x12\x0e\n\nSKYWALKING\x10\x00\x12\n\n\x06ZIPKIN\x10\x01**\n\x08SpanType\x12\t\n\x05\x45ntry\x10\x00\x12\x08\n\x04\x45xit\x10\x01\x12\t\n\x05Local\x10\x02*,\n\x07RefType\x12\x10\n\x0c\x43rossProcess\x10\x00\x12\x0f\n\x0b\x43rossThread\x10\x01*_\n\tSpanLayer\x12\x0b\n\x07Unknown\x10\x00\x12\x0c\n\x08\x44\x61tabase\x10\x01\x12\x10\n\x0cRPCFramework\x10\x02\x12\x08\n\x04Http\x10\x03\x12\x06\n\x02MQ\x10\x04\x12\t\n\x05\x43\x61\x63he\x10\x05\x12\x08\n\x04\x46\x41\x41S\x10\x06\x32\xaf\x01\n\x19TraceSegmentReportService\x12\x44\n\x07\x63ollect\x12\x1c.skywalking.v3.SegmentObject\x1a\x17.skywalking.v3.Commands\"\x00(\x01\x12L\n\rcollectInSync\x12 .skywalking.v3.SegmentCollection\x1a\x17.skywalking.v3.Commands\"\x00\x32j\n\x1eSpanAttachedEventReportService\x12H\n\x07\x63ollect\x12 .skywalking.v3.SpanAttachedEvent\x1a\x17.skywalking.v3.Commands\"\x00(\x01\x42\x93\x01\n3org.apache.skywalking.apm.network.language.agent.v3P\x01Z:skywalking.apache.org/repo/goapi/collect/language/agent/v3\xaa\x02\x1dSkyWalking.NetworkProtocol.V3b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Skywalking
  module V3
    SegmentObject = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SegmentObject").msgclass
    SegmentReference = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SegmentReference").msgclass
    SpanObject = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SpanObject").msgclass
    Log = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Log").msgclass
    ID = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.ID").msgclass
    SegmentCollection = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SegmentCollection").msgclass
    SpanAttachedEvent = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SpanAttachedEvent").msgclass
    SpanAttachedEvent::SpanReference = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SpanAttachedEvent.SpanReference").msgclass
    SpanAttachedEvent::SpanReferenceType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SpanAttachedEvent.SpanReferenceType").enummodule
    SpanType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SpanType").enummodule
    RefType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.RefType").enummodule
    SpanLayer = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.SpanLayer").enummodule
  end
end
