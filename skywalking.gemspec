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

require File.expand_path('lib/skywalking/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'skywalking'
  spec.version = Skywalking::VERSION
  spec.authors = ['Apache SkyWalking Team']
  spec.email = ['dev@skywalking.apache.org']

  spec.summary = 'Skywalking Ruby Agent'
  spec.description = 'The Ruby Agent for Apache SkyWalking'
  spec.homepage = 'https://skywalking.apache.org/'
  spec.license = 'Apache-2.0'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/apache/skywalking-ruby'
  spec.metadata["changelog_uri"] = 'https://github.com/apache/skywalking-ruby/blob/main/CHANGELOG.md'

  files =
    begin
      `git ls-files`.split("\n")
    rescue StandardError
      Dir.glob("**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
    end
  spec.files = files
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Communication with OAP
  spec.add_dependency 'grpc', '1.68.1'

  # Base dev dependency
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '13.2.1'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rubocop', '1.69.2'
  spec.add_development_dependency 'rubocop-performance', '1.23.0'
  spec.add_development_dependency 'bigdecimal', '3.1.5'

  # E2E test dependency
  spec.add_development_dependency 'redis', '~> 5.0'
  spec.add_development_dependency 'sinatra', '~> 4.1'
  spec.add_development_dependency 'testcontainers-compose', '~> 0.2.0'
  spec.add_development_dependency 'faraday', '~> 2.12'
  spec.add_development_dependency 'rspec-wait', '~> 1.0'
end
