# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: asyncprofiler/AsyncProfiler.proto

require 'google/protobuf'

require_relative '../common/Command_pb'


descriptor_data = "\n!asyncprofiler/AsyncProfiler.proto\x12\x0eskywalking.v10\x1a\x14\x63ommon/Command.proto\"\x81\x01\n\x11\x41syncProfilerData\x12\x37\n\x08metaData\x18\x01 \x01(\x0b\x32%.skywalking.v10.AsyncProfilerMetaData\x12\x16\n\x0c\x65rrorMessage\x18\x02 \x01(\tH\x00\x12\x11\n\x07\x63ontent\x18\x03 \x01(\x0cH\x00\x42\x08\n\x06result\"U\n\x1f\x41syncProfilerCollectionResponse\x12\x32\n\x04type\x18\x01 \x01(\x0e\x32$.skywalking.v10.AsyncProfilingStatus\"\x9a\x01\n\x15\x41syncProfilerMetaData\x12\x0f\n\x07service\x18\x01 \x01(\t\x12\x17\n\x0fserviceInstance\x18\x02 \x01(\t\x12\x0e\n\x06taskId\x18\x03 \x01(\t\x12\x32\n\x04type\x18\x04 \x01(\x0e\x32$.skywalking.v10.AsyncProfilingStatus\x12\x13\n\x0b\x63ontentSize\x18\x05 \x01(\x05\"b\n\x1d\x41syncProfilerTaskCommandQuery\x12\x0f\n\x07service\x18\x01 \x01(\t\x12\x17\n\x0fserviceInstance\x18\x02 \x01(\t\x12\x17\n\x0flastCommandTime\x18\x03 \x01(\x03*c\n\x14\x41syncProfilingStatus\x12\x15\n\x11PROFILING_SUCCESS\x10\x00\x12\x18\n\x14\x45XECUTION_TASK_ERROR\x10\x01\x12\x1a\n\x16TERMINATED_BY_OVERSIZE\x10\x02\x32\xde\x01\n\x11\x41syncProfilerTask\x12\x61\n\x07\x63ollect\x12!.skywalking.v10.AsyncProfilerData\x1a/.skywalking.v10.AsyncProfilerCollectionResponse(\x01\x30\x01\x12\x66\n\x1cgetAsyncProfilerTaskCommands\x12-.skywalking.v10.AsyncProfilerTaskCommandQuery\x1a\x17.skywalking.v3.CommandsB\xa6\x01\n<org.apache.skywalking.apm.network.language.asyncprofiler.v10P\x01ZCskywalking.apache.org/repo/goapi/collect/language/asyncprofiler/v10\xaa\x02\x1eSkyWalking.NetworkProtocol.V10b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Skywalking
  module V10
    AsyncProfilerData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v10.AsyncProfilerData").msgclass
    AsyncProfilerCollectionResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v10.AsyncProfilerCollectionResponse").msgclass
    AsyncProfilerMetaData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v10.AsyncProfilerMetaData").msgclass
    AsyncProfilerTaskCommandQuery = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v10.AsyncProfilerTaskCommandQuery").msgclass
    AsyncProfilingStatus = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v10.AsyncProfilingStatus").enummodule
  end
end