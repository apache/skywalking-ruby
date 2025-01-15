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

require_relative '../../../lib/skywalking'
require 'sinatra'
require 'elasticsearch'

Skywalking.start(disable_plugins: 'net_http')

def create_index(client)
  client.indices.create(index: 'test_index', body: { mappings: { properties: { name: { type: 'text' } } } })
  puts "Index created."
end

def add_document(client, id, name)
  client.index(index: 'test_index', id: id, body: { name: name })
  puts "Document added: #{id} => #{name}"
end

def get_document(client, id)
  response = client.get(index: 'test_index', id: id)
  puts "Document retrieved: #{response['_source']}"
rescue Elasticsearch::Transport::Transport::Errors::NotFound
  puts "Document not found."
end

def delete_document(client, id)
  client.delete(index: 'test_index', id: id)
  puts "Document deleted: #{id}"
end

get "/execute" do
  client = Elasticsearch::Client.new(hosts: ['http://elasticsearch:9200'], log: true, 
    transport_options: { request: { timeout: 5 } })
  create_index(client)
  add_document(client, '1', 'Document 1')
  get_document(client, '1')
  delete_document(client, '1')
end

set :bind, '0.0.0.0'
set :port, 8080