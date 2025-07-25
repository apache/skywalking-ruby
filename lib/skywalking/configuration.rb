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
      :namespace => {
        type: :string,
        default: '',
        desc: 'The namespace of the service'
      },
      :environment => {
        type: :string,
        default: '',
        desc: 'The name of the environment this service is deployed in'
      },
      :collector_backend_services => {
        type: :string,
        default: '127.0.0.1:11800',
        desc: 'Backend service addresses'
      },
      :config_file => {
        type: :string,
        default: '',
        desc: 'The absolute path to the configuration file'
      },
      :log_file_name => {
        type: :string,
        default: 'skywalking',
        desc: 'The name of the log file'
      },
      :log_file_path => {
        type: :string,
        default: '',
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
        desc: "The plugins to disable, multiple names should be split by comma, e.g. 'redis5,elasticsearch'"
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
      :meter_reporter_active => {
        type: :bool,
        default: true,
        desc: 'Enable meter reporter'
      },
      :runtime_meter_reporter_active => {
        type: :bool,
        default: true,
        desc: 'Enable Ruby runtime meter reporter'
      },
      :meter_report_period => {
        type: :int,
        default: 60,
        desc: 'Meter report period in seconds'
      },
      :max_meter_queue_size => {
        type: :int,
        default: 1000,
        desc: 'Maximum meter queue size'
      },
      :log_reporter_active => {
        type: :bool,
        default: true,
        desc: 'Enable log reporter'
      },
      :log_reporter_level => {
        type: :int,
        default: Logger::INFO,
        desc: 'Minimum log level to report (Logger::DEBUG, Logger::INFO, Logger::WARN, Logger::ERROR, Logger::FATAL)'
      },
      :log_report_period => {
        type: :int,
        default: 5,
        desc: 'Log report period in seconds'
      },
      :max_log_queue_size => {
        type: :int,
        default: 1000,
        desc: 'Maximum log queue size'
      }
    }.freeze

    # @api private
    attr_reader :agent_config, :logger

    def initialize(opts = {})
      @agent_config = {}
      initialize_config(opts)
      if @logger.nil?
        @logger ||= Mutex.new.synchronize { build_logger }
      end
    end

    def initialize_config(opts)
      # from the default value
      merge_config(DEFAULTS.transform_values { |v| v[:default] })
      # start parameters
      merge_config(opts)
      # from the custom config file
      merge_config(override_config_by_file)
      # environment variables
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
      if config_yaml.nil? || config_yaml.empty?
        config_yaml = File.join(srv_root, "config", "skywalking.yml")
      end

      unless File.exist?(config_yaml)
        return
      end

      unless srv_environment
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
        loaded_yaml = loaded_yaml[srv_environment]
        error = "Invalid format in config file" if loaded_yaml && !loaded_yaml.is_a?(Hash)
      rescue Exception => e
        error = e.message
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
        new_config[env_key] = case type
                              when :string
                                env_value.to_s
                              when :bool
                                # rubocop:disable Performance/CollectionLiteralInLoop
                                !%w[0 false].include?(env_value.strip.downcase)
                              # rubocop:enable Performance/CollectionLiteralInLoop
                              when :int
                                env_value.to_i
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

    def srv_environment
      @agent_config[:environment].to_s.empty? ? Skywalking::Environment.instance.framework_env : @agent_config[:environment]
    end

    def srv_root
      Skywalking::Environment.instance.framework_root
    end

    #####
    # LOAD LOG
    #####
    def build_logger
      return @logger if @logger

      log_dest = log_destination
      create_log(log_dest, get_log_level)
    end

    def create_log(log_dest, level)
      if log_dest.is_a?(String)
        log_dest = File.expand_path(log_dest, Pathname.new(Dir.pwd).realpath)
        FileUtils.mkdir_p(File.dirname(log_dest))
      end

      begin
        logger = ::Logger.new(log_dest, progname: "Skywalking", level: level)
        logger.formatter = log_formatter

        logger
      rescue => e
        logger = ::Logger.new($stdout, progname: "Skywalking", level: level)
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
      candidate = @agent_config[:log_file_path].upcase

      case candidate
      when "STDOUT"
        $stdout
      when "STDERR"
        $stderr
      when nil? || ''
        $stdout
      else
        "#{@agent_config[:log_file_path]}/#{@agent_config[:log_file_name]}.log"
      end
    end

    def get_log_level
      candidate = @agent_config[:log_level].downcase

      case candidate
      when "debug" then ::Logger::DEBUG
      when "info" then ::Logger::INFO
      when "warn" then ::Logger::WARN
      when "error" then ::Logger::ERROR
      when "fatal" then ::Logger::FATAL
      when ::Logger::DEBUG, ::Logger::INFO, ::Logger::WARN, ::Logger::ERROR, ::Logger::FATAL then candidate
      else ::Logger::INFO
      end
    end
  end
end