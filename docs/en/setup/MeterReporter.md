# Ruby Agent Meter Reporter

The meter reporter feature enables collection and reporting of runtime metrics to the SkyWalking OAP backend.

## Features

### Runtime Metrics (Enabled by Default)

The agent automatically collects Ruby runtime metrics when `meter_reporter_active` and `runtime_meter_reporter_active` are enabled (default: true).

#### Collected Metrics

**CPU Metrics:**
- `instance_ruby_total_cpu_utilization` - System total CPU usage percentage
- `instance_ruby_process_cpu_utilization` - Ruby process CPU usage percentage

**Memory Metrics:**
- `instance_ruby_total_mem_utilization` - System total memory usage percentage
- `instance_ruby_process_mem_utilization` - Ruby process memory usage percentage

**Garbage Collection Metrics:**
- `instance_ruby_gc_count` - Total GC execution count
- `instance_ruby_gc_time` - GC execution time (milliseconds)
- `instance_ruby_gc_minor_count` - Minor GC count (if available)
- `instance_ruby_gc_major_count` - Major GC count (if available)
- `instance_ruby_heap_live_slots` - Number of live heap slots
- `instance_ruby_heap_free_slots` - Number of free heap slots

**Thread Metrics:**
- `instance_ruby_thread_active_count` - Number of active threads
- `instance_ruby_thread_count` - Total thread count
- `instance_ruby_fiber_count` - Total fiber count

## Configuration

### Enable/Disable Meter Reporter

```ruby
# Enable meter reporter (default: true)
config[:meter_reporter_active] = true

# Enable runtime metrics (default: true)
config[:runtime_meter_reporter_active] = true

# Or via environment variables
ENV['SW_AGENT_METER_REPORTER_ACTIVE'] = 'true'
ENV['SW_AGENT_RUNTIME_METER_REPORTER_ACTIVE'] = 'true'
```

### Configure Report Period

```ruby
# Set meter report period in seconds (default: 20)
config[:meter_report_period] = 20

# Set maximum meter queue size (default: 1000)
config[:max_meter_queue_size] = 1000
```
