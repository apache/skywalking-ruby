# Tracing Plugins

The following plugins provide the distributed tracing capability, and the OAP backend would analyze the topology and
metrics based on the tracing data.

| Library                                                        | Version  | Plugin Name     |
|:---------------------------------------------------------------|:---------|:----------------|
| [redis](https://github.com/redis/redis-rb)                     | ~> 5.0   | `redis5`        |
| [net-http](https://github.com/ruby/net-http)                   | ~> 0.6.0 | `net_http`      |
| [sinatra](https://github.com/sinatra/sinatra)                  | ~> 4.1   | `sinatra`       |
| [memcached](https://github.com/petergoldstein/dalli)           | ~> 3.2   | `memcached`     |
| [elasticsearch](https://github.com/elastic/elasticsearch-ruby) | ~> 8.0.0 | `elasticsearch` |