# Logging Standardizer Skill

## Skill ID
`logging-standardizer`

## Category
📊 Observability

## Responsibility
Define structured JSON logs, error severity mapping, Kubernetes log compatibility, and standardized logging patterns for cloud-native applications.

## Inputs

```yaml
inputs:
  application:
    name: string
    environment: string         # "development" | "staging" | "production"
    version: string
  logging_config:
    format: string              # "json" | "text"
    level: string               # "debug" | "info" | "warn" | "error"
    output: string              # "stdout" | "file" | "both"
  kubernetes_integration:
    enabled: boolean
    namespace: string
    pod_labels: object
```

## Outputs

```yaml
outputs:
  logging_schema:
    structure: object           # JSON log structure
    required_fields: array
    optional_fields: array
  log_levels:
    severity_mapping: object
    kubernetes_compatible: boolean
```

## Algorithm

1. **Log Structure Definition**
   - Define JSON schema for logs
   - Specify required fields
   - Add contextual metadata
   - Ensure Kubernetes compatibility

2. **Severity Level Mapping**
   - Map application levels to standard levels
   - Define severity hierarchy
   - Configure level filtering
   - Support dynamic level changes

3. **Kubernetes Integration**
   - Add pod/container metadata
   - Support log aggregation
   - Enable log streaming
   - Configure retention policies

4. **Performance Optimization**
   - Minimize log overhead
   - Implement sampling for high-volume logs
   - Use async logging
   - Buffer log writes

## Structured Log Schema

```json
{
  "timestamp": "2026-02-16T10:30:45.123Z",
  "level": "info",
  "message": "User created todo",
  "service": "todo-backend",
  "version": "1.2.0",
  "environment": "production",
  "trace_id": "abc123def456",
  "span_id": "span789",
  "user_id": "user123",
  "request_id": "req-xyz789",
  "method": "POST",
  "path": "/api/todos",
  "status_code": 201,
  "duration_ms": 45,
  "error": null,
  "metadata": {
    "todo_id": "todo-456",
    "action": "create"
  },
  "kubernetes": {
    "namespace": "production",
    "pod": "todo-backend-7d8f9c-abc12",
    "container": "todo-backend",
    "node": "node-1"
  }
}
```

## Log Level Definitions

```yaml
log_levels:
  debug:
    severity: 0
    description: "Detailed diagnostic information"
    use_cases:
      - "Variable values"
      - "Function entry/exit"
      - "Detailed flow tracing"
    kubernetes_severity: "DEBUG"
    color: "gray"
    enabled_in:
      - "development"

  info:
    severity: 1
    description: "General informational messages"
    use_cases:
      - "Request received"
      - "Operation completed"
      - "State changes"
    kubernetes_severity: "INFO"
    color: "blue"
    enabled_in:
      - "development"
      - "staging"
      - "production"

  warn:
    severity: 2
    description: "Warning messages for potentially harmful situations"
    use_cases:
      - "Deprecated API usage"
      - "Retry attempts"
      - "Performance degradation"
    kubernetes_severity: "WARNING"
    color: "yellow"
    enabled_in:
      - "development"
      - "staging"
      - "production"

  error:
    severity: 3
    description: "Error events that might still allow the application to continue"
    use_cases:
      - "Failed operations"
      - "Caught exceptions"
      - "Invalid input"
    kubernetes_severity: "ERROR"
    color: "red"
    enabled_in:
      - "development"
      - "staging"
      - "production"

  fatal:
    severity: 4
    description: "Severe errors causing application termination"
    use_cases:
      - "Unrecoverable errors"
      - "Critical system failures"
      - "Application crashes"
    kubernetes_severity: "CRITICAL"
    color: "red"
    enabled_in:
      - "development"
      - "staging"
      - "production"
```

## Logger Implementation (TypeScript)

```typescript
interface LogEntry {
  timestamp: string;
  level: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
  message: string;
  service: string;
  version: string;
  environment: string;
  trace_id?: string;
  span_id?: string;
  user_id?: string;
  request_id?: string;
  method?: string;
  path?: string;
  status_code?: number;
  duration_ms?: number;
  error?: {
    name: string;
    message: string;
    stack?: string;
  };
  metadata?: Record<string, any>;
  kubernetes?: {
    namespace: string;
    pod: string;
    container: string;
    node: string;
  };
}

class StructuredLogger {
  private service: string;
  private version: string;
  private environment: string;
  private minLevel: number;

  constructor(config: {
    service: string;
    version: string;
    environment: string;
    level?: string;
  }) {
    this.service = config.service;
    this.version = config.version;
    this.environment = config.environment;
    this.minLevel = this.getLevelValue(config.level || 'info');
  }

  private getLevelValue(level: string): number {
    const levels: Record<string, number> = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
      fatal: 4
    };
    return levels[level] || 1;
  }

  private shouldLog(level: string): boolean {
    return this.getLevelValue(level) >= this.minLevel;
  }

  private createLogEntry(
    level: 'debug' | 'info' | 'warn' | 'error' | 'fatal',
    message: string,
    context?: Partial<LogEntry>
  ): LogEntry {
    return {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: this.service,
      version: this.version,
      environment: this.environment,
      ...context,
      kubernetes: this.getKubernetesMetadata()
    };
  }

  private getKubernetesMetadata() {
    return {
      namespace: process.env.K8S_NAMESPACE || 'default',
      pod: process.env.K8S_POD_NAME || 'unknown',
      container: process.env.K8S_CONTAINER_NAME || 'unknown',
      node: process.env.K8S_NODE_NAME || 'unknown'
    };
  }

  private write(entry: LogEntry): void {
    if (!this.shouldLog(entry.level)) {
      return;
    }

    // Write to stdout as JSON (Kubernetes will capture this)
    console.log(JSON.stringify(entry));
  }

  debug(message: string, context?: Partial<LogEntry>): void {
    this.write(this.createLogEntry('debug', message, context));
  }

  info(message: string, context?: Partial<LogEntry>): void {
    this.write(this.createLogEntry('info', message, context));
  }

  warn(message: string, context?: Partial<LogEntry>): void {
    this.write(this.createLogEntry('warn', message, context));
  }

  error(message: string, error?: Error, context?: Partial<LogEntry>): void {
    const errorContext = error ? {
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack
      }
    } : {};

    this.write(this.createLogEntry('error', message, {
      ...context,
      ...errorContext
    }));
  }

  fatal(message: string, error?: Error, context?: Partial<LogEntry>): void {
    const errorContext = error ? {
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack
      }
    } : {};

    this.write(this.createLogEntry('fatal', message, {
      ...context,
      ...errorContext
    }));
  }

  // HTTP request logging
  logRequest(req: any, res: any, duration: number): void {
    this.info('HTTP request', {
      method: req.method,
      path: req.path,
      status_code: res.statusCode,
      duration_ms: duration,
      user_id: req.user?.id,
      request_id: req.id,
      trace_id: req.headers['x-trace-id']
    });
  }

  // Database query logging
  logQuery(query: string, duration: number, success: boolean): void {
    const level = success ? 'debug' : 'error';
    this[level]('Database query', {
      duration_ms: duration,
      metadata: {
        query: query.substring(0, 100), // Truncate long queries
        success
      }
    });
  }
}
```

## Logger Usage Examples

```typescript
// Initialize logger
const logger = new StructuredLogger({
  service: 'todo-backend',
  version: '1.2.0',
  environment: process.env.NODE_ENV || 'development',
  level: process.env.LOG_LEVEL || 'info'
});

// Basic logging
logger.info('Application started');
logger.debug('Configuration loaded', {
  metadata: { config_keys: ['database', 'redis', 'auth'] }
});

// HTTP request logging
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.logRequest(req, res, duration);
  });

  next();
});

// Error logging
try {
  await createTodo(data);
} catch (error) {
  logger.error('Failed to create todo', error as Error, {
    user_id: userId,
    metadata: { todo_data: data }
  });
}

// Business event logging
logger.info('Todo created', {
  user_id: userId,
  metadata: {
    todo_id: todo.id,
    title: todo.title,
    action: 'create'
  }
});
```

## Kubernetes Log Collection

```yaml
kubernetes_logging:
  log_output:
    destination: "stdout"
    format: "json"
    reason: "Kubernetes captures stdout/stderr automatically"

  log_aggregation:
    tools:
      - "Fluentd"
      - "Fluent Bit"
      - "Promtail (Loki)"
    configuration: |
      # Fluentd configuration
      <source>
        @type tail
        path /var/log/containers/*.log
        pos_file /var/log/fluentd-containers.log.pos
        tag kubernetes.*
        read_from_head true
        <parse>
          @type json
          time_key timestamp
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </parse>
      </source>

  log_storage:
    options:
      - "Elasticsearch"
      - "Loki"
      - "CloudWatch Logs"
      - "Stackdriver"
    retention:
      development: "7 days"
      staging: "30 days"
      production: "90 days"
```

## Log Sampling Strategy

```yaml
sampling:
  high_volume_endpoints:
    description: "Sample logs for high-traffic endpoints"
    endpoints:
      - "/health"
      - "/metrics"
      - "/ready"
    sample_rate: 0.01  # Log 1% of requests

  error_logs:
    description: "Always log errors"
    sample_rate: 1.0   # Log 100% of errors

  debug_logs:
    description: "Sample debug logs in production"
    environments:
      development: 1.0
      staging: 0.5
      production: 0.1
```

## Performance Considerations

```yaml
performance:
  async_logging:
    enabled: true
    buffer_size: 1000
    flush_interval: 1000  # ms

  log_rotation:
    enabled: false  # Kubernetes handles this
    reason: "Kubernetes rotates logs automatically"

  structured_logging_overhead:
    json_serialization: "~0.1ms per log"
    acceptable_overhead: "< 1% of request time"

  optimization_tips:
    - "Use appropriate log levels"
    - "Avoid logging in tight loops"
    - "Sample high-volume logs"
    - "Truncate large payloads"
    - "Use async logging"
```

## Log Query Examples

```yaml
query_examples:
  find_errors:
    query: 'level="error" AND service="todo-backend"'
    tool: "Loki/Elasticsearch"

  trace_request:
    query: 'trace_id="abc123def456"'
    description: "Find all logs for a specific request"

  user_activity:
    query: 'user_id="user123" AND timestamp > now() - 1h'
    description: "Find user activity in last hour"

  slow_requests:
    query: 'duration_ms > 1000 AND path="/api/todos"'
    description: "Find slow API requests"

  pod_logs:
    query: 'kubernetes.pod="todo-backend-7d8f9c-abc12"'
    description: "Find logs from specific pod"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl logs -l app=todo-backend --tail=10"
    description: "View recent logs from pods"
    success_criteria: "JSON formatted logs displayed"

  - command: "kubectl logs -l app=todo-backend | jq '.level'"
    description: "Verify log structure"
    success_criteria: "Log levels extracted successfully"

  - command: "kubectl logs -l app=todo-backend | jq 'select(.level==\"error\")'"
    description: "Filter error logs"
    success_criteria: "Only error logs displayed"
```

## Best Practices

```yaml
best_practices:
  do:
    - "Use structured JSON logging"
    - "Include trace/request IDs"
    - "Log at appropriate levels"
    - "Include contextual metadata"
    - "Use consistent field names"
    - "Log to stdout in Kubernetes"
    - "Sanitize sensitive data"

  dont:
    - "Log passwords or secrets"
    - "Log PII without masking"
    - "Use string concatenation for logs"
    - "Log in tight loops"
    - "Use blocking I/O for logging"
    - "Log entire request/response bodies"
    - "Mix log formats (JSON + text)"
```

## Integration Points

- **Depends On**: Application runtime, Kubernetes environment
- **Next Skill**: `error-monitoring-setup` (error detection)
- **Outputs To**: Log aggregation systems (Fluentd, Loki)

## Performance Targets

- Log write latency: < 1ms (async)
- JSON serialization: < 0.1ms per log
- Overhead: < 1% of request time
- Buffer flush: Every 1 second or 1000 logs

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
