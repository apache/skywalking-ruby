# Quick Start

## Requirements

**SkyWalking Ruby agent requires SkyWalking 8.0+ and Ruby 3.0+**

## Installing the gem

The Ruby agent's gem is available from [RubyGems](https://rubygems.org/) as `skywalking`, we recommend you install and
manage the skywalking gem dependency with [Bundler](http://bundler.io/), add the following line to your `Gemfile`, then
run `bundle install` to install the gem.

~~~ruby
# Gemfile
source "https://rubygems.org"

gem "skywalking"
~~~

Besides, you can also make installation as simple as `gem install skywalking`.

## Installing from Source Code

**Download the source tar from the [official website](http://skywalking.apache.org/downloads/), and run the following commands to build from source**

**Make sure you have Ruby 3.0+ and the `gem` command available**

~~~shell
tar -zxf skywalking-ruby-src-<version>.tgz
cd skywalking-ruby-src-<version>
gem build skywalking.gemspec
~~~

If successful, the following will be displayed:

```shell
  Successfully built RubyGem
  Name: skywalking
  Version: <version>
  File: skywalking-<version>.gem
```

Then you can use `skywalking-<version>.gem` to your gemfile.

## Getting started with Rails

You need to manually add `Skywalking.start` under config/initializers directory.

Optionally the command `bundle exec rails generate skywalking:start`, will create a config file
`config/initializers/skywalking.rb`, and then you can configure the start parameters.

## Getting started with Sinatra

You can list `gem 'skywalking'` after sinatra in your Gemfile and use `Bundler.require` during initialization or calling
`require 'skywalking'` after sinatra gem is loaded, that is, skywalking gem needs to be after the other gems you
require (e.g. redis, elasticsearch), like the following code:

~~~ruby
require 'redis'
require 'sinatra'
require 'skywalking'

Skywalking.start

get '/sw' do
  "Hello, SkyWalking!"
end
~~~

## Configuration

You can configure the SkyWalking Ruby agent in various ways, the Ruby agent follows this order of precedence for
configuration:

- Defaults (please
  see [DEFAULTS](https://github.com/apache/skywalking-ruby/blob/main/lib/skywalking/configuration.rb#L21))
- Arguments to `Skywalking.start`
- Configuration file (e.g. `conifg/skywalking.yml`)
- Environment variables

The following is an example of configuration at start:

~~~ruby
Skywalking.start(
  service_name: 'sw-srv',
  instance_name: 'sw-inst',
  collector_backend_services: 'oap:11800',
  meter_reporter_active: true,
  log_reporter_active: true,
  meter_report_period: 30,
  log_report_period: 10
)
~~~

The following is an example of a configuration file:

~~~yaml
common: &defaults
  service_name: Ruby-Agent-Common
  log_level: debug
  meter_reporter_active: true
  log_reporter_active: true
  meter_report_period: 20
  log_report_period: 5

development:
  <<: *defaults
  service_name: Ruby-Agent-Development
  log_reporter_level: 0  # DEBUG

test:
  <<: *defaults
  service_name: Ruby-Agent-Test
  log_reporter_level: 1  # INFO

production:
  <<: *defaults
  service_name: Ruby-Agent-Production
  log_reporter_level: 2  # WARN
~~~

The following lists all the configuration options:

| key                             | environment key                          | default value        | description                                                                                                                               |
|---------------------------------|------------------------------------------|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| service_name                    | SW_AGENT_SERVICE_NAME                    | Your_ApplicationName | The name of the service which showed in UI.                                                                                               |
| instance_name                   | SW_AGENT_INSTANCE_NAME                   | Your_InstanceName    | To obtain the environment variable key for the instance name, if it cannot be obtained, an instance name will be automatically generated. |
| namespace                       | SW_AGENT_NAMESPACE                       | Not set              | Namespace represents a subnet, such as kubernetes namespace, or 172.10..                                                                  |
| environment                     | SW_AGENT_ENVIRONMENT                     | Not set              | The name of the environment this service is deployed in                                                                                   |
| collector_backend_services      | SW_AGENT_COLLECTOR_BACKEND_SERVICES      | 127.0.0.1:11800      | Collector SkyWalking trace receiver service addresses.                                                                                    |
| config_file                     | SW_AGENT_CONFIG_FILE                     | Not set              | The absolute path to the configuration file, if empty, it will automatically search for config/skywalking.yml in the root directory.      |
| log_file_name                   | SW_AGENT_LOG_FILE_NAME                   | skywalking           | The name of the log file.                                                                                                                 |
| log_file_path                   | SW_AGENT_LOG_FILE_PATH                   | Not set              | The path to the log file.                                                                                                                 |
| log_level                       | SW_AGENT_LOG_LEVEL                       | info                 | The log level.                                                                                                                            |
| disable_plugins                 | SW_AGENT_DISABLE_PLUGINS                 | Not set              | The plugins to disable, multiple names should be split by comma, e.g. 'redis5,elasticsearch'.                                             |
| report_protocol                 | SW_AGENT_REPORT_PROTOCOL                 | grpc                 | The protocol to use for reporting.                                                                                                        |
| re_ignore_operation             | SW_AGENT_RE_IGNORE_OPERATION             | Not set              | Ignore specific URL paths.                                                                                                                |
| instance_properties_json        | SW_AGENT_INSTANCE_PROPERTIES_JSON        | Not set              | A custom JSON string to be reported as service instance properties, e.g. `{"key": "value"}`.                                              |
| collector_heartbeat_period      | SW_AGENT_COLLECTOR_HEARTBEAT_PERIOD      | 30                   | he agent will send heartbeat to OAP every `collector_heartbeat_period` seconds.                                                           |
| properties_report_period_factor | SW_AGENT_PROPERTIES_REPORT_PERIOD_FACTOR | 10                   | The agent will report service instance properties every `collector_heartbeat_period * properties_report_period_factor` seconds.           |
| max_queue_size                  | SW_AGENT_MAX_QUEUE_SIZE                  | 10000                | The maximum queue size for reporting data.                                                                                                |
| meter_reporter_active           | SW_AGENT_METER_REPORTER_ACTIVE           | true                 | Enable/disable meter reporter for runtime metrics collection.                                                                             |
| meter_report_period             | SW_AGENT_METER_REPORT_PERIOD             | 60                   | Meter report period in seconds.                                                                                                           |
| max_meter_queue_size            | SW_AGENT_MAX_METER_QUEUE_SIZE            | 1000                 | Maximum meter queue size for buffering metrics data.                                                                                      |
| log_reporter_active             | SW_AGENT_LOG_REPORTER_ACTIVE             | true                 | Enable/disable log reporter for log collection.                                                                                           |
| log_reporter_level              | SW_AGENT_LOG_REPORTER_LEVEL              | 1 (INFO)             | Minimum log level to report (Logger::DEBUG=0, INFO=1, WARN=2, ERROR=3, FATAL=4).                                                          |
| log_report_period               | SW_AGENT_LOG_REPORT_PERIOD               | 5                    | Log report period in seconds.                                                                                                             |
| max_log_queue_size              | SW_AGENT_MAX_LOG_QUEUE_SIZE              | 1000                 | Maximum log queue size for buffering log data.                                                                                            |
