# Ruby Agent Meter and Log Reporter

The meter reporter feature enables collection and reporting of runtime metrics to the SkyWalking OAP backend.

### Runtime Metrics (Enabled by Default)

The agent automatically collects Ruby runtime metrics when `meter_reporter_active` is enabled (default: true).

#### Collected Runtime Metrics

**CPU Metrics:**

- `instance_ruby_cpu_usage_percent` - Ruby process CPU usage percentage (based on load average)

**Memory Metrics:**

- `instance_ruby_memory_rss_mb` - Ruby process RSS memory usage in MB

**Garbage Collection Metrics:**

- `instance_ruby_gc_count_total` - Total GC execution count
- `instance_ruby_gc_minor_count_total` - Minor GC count (if available)
- `instance_ruby_gc_major_count_total` - Major GC count (if available)
- `instance_ruby_heap_usage_percent` - Heap memory usage percentage
- `instance_ruby_heap_live_slots_count` - Number of live heap slots
- `instance_ruby_heap_allocated_slots_count` - Number of allocated heap slots

**Object System Metrics:**

- `instance_ruby_total_allocated_objects` - Total allocated objects count

**Thread Metrics:**

- `instance_ruby_thread_count_active` - Number of active threads

### Log Integration

When log reporter is enabled, the agent automatically:

- **Intercepts Ruby Standard Logger**: Automatically patches the `Logger` class to collect logs
- **Integrates Trace Context**: Adds trace ID, segment ID, and span ID to log messages when available

#### Supported Logger

Currently, the agent supports:

- **Ruby Standard Logger** (`Logger` class) - Automatically intercepted and collected

#### Log Configuration Options

```ruby
# Configure log reporter level (default: Logger::INFO)
config[:log_reporter_level] = Logger::INFO

# Configure log report period in seconds (default: 5)
config[:log_report_period] = 5

# Configure maximum log queue size (default: 1000)
config[:max_log_queue_size] = 1000
```
