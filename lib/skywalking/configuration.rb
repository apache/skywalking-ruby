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

require 'yaml'
require 'logger'

module Skywalking
  class Configuration
    DEFAULTS = {
      :service_name => {
        type: :string,
        default: 'Your_ApplicationName',
        desc: 'The name of your awesome Ruby service'
      },
      :instance_name => {
        type: :string,
        default: 'Your_InstanceName',
        desc: 'The name of this particular awesome Ruby service instance'
      },
      :collector_backend_service => {
        type: :string,
        default: '127.0.0.1:11800',
        desc: 'Backend service addresses'
      },
      :config_file => {
        type: :string,
        default: '',
        desc: 'The path to the config file'
      },
      :log_file => {
        type: :string,
        default: 'skywalking.log',
        desc: 'The name of the log file'
      },
      :log_file_path => {
        type: :string,
        default: 'STDOUT',
        desc: 'The path to the log file'
      },
      :log_level => {
        type: :string,
        default: 'info',
        desc: 'The log level'
      },
      :disable_plugins => {
        type: :string,
        default: '',
        desc: 'The plugins to disable'
      },
      :report_protocol => {
        type: :string,
        default: 'grpc',
        desc: 'The protocol to use for reporting'
      },
      :re_ignore_operation => {
        type: :string,
        default: '',
        desc: 'Ignore specific URL paths'
      },
      :namespace => {
        type: :string,
        default: '',
        desc: 'The namespace of the service'
      },
      :instance_properties_json => {
        type: :string,
        default: '',
        desc: 'A custom JSON string to be reported as service instance properties, e.g. `{"key": "value"}`'
      },
      :collector_heartbeat_period => {
        type: :int,
        default: 30,
        desc: 'The agent will send heartbeat to OAP every `collector_heartbeat_period` seconds'
      },
      :properties_report_period_factor => {
        type: :int,
        default: 10,
        desc: 'The agent will report service instance properties every 
              `collector_heartbeat_period * properties_report_period_factor` seconds'
      },
      :max_queue_size => {
        type: :int,
        default: 10000,
        desc: 'The maximum queue size for reporting data'
      },
    }.freeze

    # @api private
    attr_reader :agent_config

    def initialize(opts = {})
      @agent_config = {}
      initialize_config(opts)
    end

    def initialize_config(opts)
      # from the default value
      merge_config(DEFAULTS.transform_values { |v| v[:default] })
      merge_config(opts)
      # from the custom config file
      merge_config(override_config_by_file)
      merge_config(override_config_by_env)
    end

    def merge_config(new_config)
      return if new_config.nil?

      new_config.each do |k, v|
        @agent_config[k.to_sym] = v
      end
    end

    def override_config_by_file
      config_yaml = @agent_config[:config_file]
      return if config_yaml.nil? || config_yaml.empty?

      unless File.exist?(config_yaml)
        logger.warn "No config file found at #{config_yaml}"
        return
      end

      error = nil
      begin
        raw_file = File.read(config_yaml)
        erb_file = ERB.new(raw_file).result(binding)
        loaded_yaml = if YAML.respond_to?(:unsafe_load)
                        YAML.unsafe_load(erb_file)
                      else
                        YAML.safe_load(erb_file, permitted_classes: [], permitted_symbols: [], aliases: true)
                      end
        error = "Invalid format in config file" if loaded_yaml && !loaded_yaml.is_a?(Hash)
      rescue Exception => e
        error = e.message
        logger.error "override config by file failed, error=%s", e.message
        nil
      end
      raise StandardError, "Error loading config file: #{config_yaml} - #{error}" if error

      loaded_yaml
    end

    def override_config_by_env
      new_config = {}
      DEFAULTS.each do |env_key, env_schema|
        env_value = ENV.fetch(key_to_env_key(env_key), nil)
        next if env_value.nil?

        type = env_schema[:type]
        case type
        when :string
          new_config[env_key] = env_value.to_s
        when :bool
          # rubocop:disable Performance/CollectionLiteralInLoop
          new_config[env_key] = !%w[0 false].include?(env_value.strip.downcase)
          # rubocop:enable Performance/CollectionLiteralInLoop
        when :int
          new_config[env_key] = env_value.to_s
        else
          env_value
        end
      end

      new_config
    end

    def key_to_env_key(key)
      'SW_AGENT_' + key.to_s.upcase
    end

    def freeze
      super
      @agent_config.freeze
      @agent_config.transform_values(&:freeze)

      self
    end

    #####
    # LOAD LOG
    #####
    def logger
      @logger ||= Mutex.new.synchronize { get_logger }
    end

    def get_logger
      return @logger if @logger

      log_dest = log_destination
      create_log(log_dest, get_log_level)
    end

    def create_log(log_dest, level)
      if log_dest.is_a?(String)
        log_dest = File.expand_path(out, Pathname.new(Dir.pwd).realpath)
        FileUtils.mkdir_p(File.dirname(log_dest))
      end

      begin
        logger = ::Logger.new(log_dest, progname: "Skywalking-Ruby", level: level)
        logger.formatter = log_formatter

        logger
      rescue => e
        logger = ::Logger.new($stdout, progname: "Skywalking-Ruby", level: level)
        logger.warn "Create logger for file #{log_dest} failed, using standard out for logging error=#{e.message}"
      end
    end

    def log_formatter
      ->(severity, datetime, program, message) do
        datetime = datetime.strftime("%Y-%m-%dT%H:%M:%S")
        "[#{datetime}] - #{severity} - [#{program}] #{message}\n"
      end
    end

    def log_destination
      if stdout?
        $stdout
      elsif !agent_config[:log_file].nil?
        agent_config[:log_file]
      elsif !agent_config[:log_file_path].nil?
        "#{agent_config[:log_file_path]}/skywalking.log"
      else
        $stdout
      end
    end

    def get_log_level
      case @agent_config[:log_level]
      when "debug" then ::Logger::DEBUG
      when "info" then ::Logger::INFO
      when "warn" then ::Logger::WARN
      when "error" then ::Logger::ERROR
      when "fatal" then ::Logger::FATAL
      else ::Logger::INFO
      end
    end

    def stdout?
      @agent_config[:log_file_path] == "STDOUT"
    end
  end
end