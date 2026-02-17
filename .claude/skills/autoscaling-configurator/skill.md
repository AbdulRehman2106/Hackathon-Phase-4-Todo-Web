# Autoscaling Configurator Skill

## Skill ID
`autoscaling-configurator`

## Category
☸️ Kubernetes

## Responsibility
Define HPA (Horizontal Pod Autoscaler) configuration, CPU threshold scaling, memory-based scaling, and replica auto-adjustment for Kubernetes deployments.

## Inputs

```yaml
inputs:
  application:
    name: string
    deployment_name: string
  scaling_config:
    enabled: boolean
    min_replicas: integer
    max_replicas: integer
  metrics:
    cpu:
      enabled: boolean
      target_utilization: integer  # Percentage (e.g., 80)
    memory:
      enabled: boolean
      target_utilization: integer  # Percentage (e.g., 80)
    custom_metrics: array          # Optional custom metrics
  behavior:
    scale_up:
      stabilization_window: integer  # Seconds
      policies: array
    scale_down:
      stabilization_window: integer
      policies: array
  environment: string              # "development" | "staging" | "production"
```

## Outputs

```yaml
outputs:
  hpa_config:
    manifest: string               # YAML HPA manifest
    metrics_configured: array
    scaling_thresholds: object
  scaling_policy:
    scale_up_behavior: object
    scale_down_behavior: object
    stabilization_windows: object
```

## Algorithm

1. **Metrics Selection**
   - Determine which metrics to use (CPU, memory, custom)
   - Set appropriate target utilization percentages
   - Configure metric collection intervals

2. **Replica Bounds Configuration**
   - Set minimum replicas (ensure availability)
   - Set maximum replicas (cost control)
   - Consider environment-specific limits

3. **Scaling Behavior Design**
   - Configure scale-up policies (aggressive)
   - Configure scale-down policies (conservative)
   - Set stabilization windows to prevent flapping

4. **Validation**
   - Verify metrics server is installed
   - Test scaling triggers
   - Monitor scaling events

## HPA Manifest Template

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{APP_NAME}}-hpa
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{DEPLOYMENT_NAME}}
  minReplicas: {{MIN_REPLICAS}}
  maxReplicas: {{MAX_REPLICAS}}
  metrics:
  {{#if CPU_ENABLED}}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{CPU_TARGET}}
  {{/if}}
  {{#if MEMORY_ENABLED}}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{MEMORY_TARGET}}
  {{/if}}
  {{#each CUSTOM_METRICS}}
  - type: {{this.type}}
    {{this.type}}:
      {{#if this.metric}}
      metric:
        name: {{this.metric.name}}
        {{#if this.metric.selector}}
        selector:
          matchLabels:
            {{#each this.metric.selector.matchLabels}}
            {{@key}}: {{this}}
            {{/each}}
        {{/if}}
      {{/if}}
      target:
        type: {{this.target.type}}
        {{#if this.target.averageValue}}
        averageValue: {{this.target.averageValue}}
        {{/if}}
        {{#if this.target.value}}
        value: {{this.target.value}}
        {{/if}}
  {{/each}}
  behavior:
    scaleUp:
      stabilizationWindowSeconds: {{SCALE_UP_STABILIZATION}}
      policies:
      {{#each SCALE_UP_POLICIES}}
      - type: {{this.type}}
        value: {{this.value}}
        periodSeconds: {{this.periodSeconds}}
      {{/each}}
      selectPolicy: {{SCALE_UP_SELECT_POLICY}}
    scaleDown:
      stabilizationWindowSeconds: {{SCALE_DOWN_STABILIZATION}}
      policies:
      {{#each SCALE_DOWN_POLICIES}}
      - type: {{this.type}}
        value: {{this.value}}
        periodSeconds: {{this.periodSeconds}}
      {{/each}}
      selectPolicy: {{SCALE_DOWN_SELECT_POLICY}}
```

## Environment-Specific Configurations

```yaml
development:
  enabled: false
  reason: "Fixed replica count for predictable development"
  alternative: "Use fixed replicas: 1"

staging:
  enabled: true
  min_replicas: 2
  max_replicas: 5
  metrics:
    cpu:
      enabled: true
      target_utilization: 70
    memory:
      enabled: true
      target_utilization: 80
  behavior:
    scale_up:
      stabilization_window: 60
      policies:
        - type: "Percent"
          value: 50
          period_seconds: 60
    scale_down:
      stabilization_window: 300
      policies:
        - type: "Percent"
          value: 25
          period_seconds: 60

production:
  enabled: true
  min_replicas: 3
  max_replicas: 20
  metrics:
    cpu:
      enabled: true
      target_utilization: 80
    memory:
      enabled: true
      target_utilization: 85
  behavior:
    scale_up:
      stabilization_window: 0
      policies:
        - type: "Percent"
          value: 100
          period_seconds: 15
        - type: "Pods"
          value: 4
          period_seconds: 15
      select_policy: "Max"
    scale_down:
      stabilization_window: 300
      policies:
        - type: "Percent"
          value: 10
          period_seconds: 60
      select_policy: "Min"
```

## Scaling Behavior Policies

```yaml
scale_up_policies:
  aggressive:
    description: "Scale up quickly to handle traffic spikes"
    stabilization_window: 0
    policies:
      - type: "Percent"
        value: 100
        period_seconds: 15
      - type: "Pods"
        value: 4
        period_seconds: 15
    select_policy: "Max"
    use_case: "Production, traffic-sensitive applications"

  moderate:
    description: "Balanced scale-up approach"
    stabilization_window: 60
    policies:
      - type: "Percent"
        value: 50
        period_seconds: 60
    select_policy: "Max"
    use_case: "Staging, cost-conscious environments"

  conservative:
    description: "Slow, controlled scale-up"
    stabilization_window: 120
    policies:
      - type: "Pods"
        value: 1
        period_seconds: 120
    select_policy: "Min"
    use_case: "Development, resource-limited clusters"

scale_down_policies:
  aggressive:
    description: "Scale down quickly to save costs"
    stabilization_window: 60
    policies:
      - type: "Percent"
        value: 50
        period_seconds: 60
    select_policy: "Max"
    use_case: "Development, non-critical workloads"

  moderate:
    description: "Balanced scale-down approach"
    stabilization_window: 300
    policies:
      - type: "Percent"
        value: 25
        period_seconds: 60
    select_policy: "Min"
    use_case: "Staging environments"

  conservative:
    description: "Very slow scale-down to maintain availability"
    stabilization_window: 600
    policies:
      - type: "Percent"
        value: 10
        period_seconds: 120
      - type: "Pods"
        value: 1
        period_seconds: 300
    select_policy: "Min"
    use_case: "Production, high-availability requirements"
```

## Custom Metrics Examples

```yaml
custom_metrics:
  requests_per_second:
    type: "Pods"
    pods:
      metric:
        name: "http_requests_per_second"
      target:
        type: "AverageValue"
        averageValue: "1000"
    description: "Scale based on HTTP requests per second"

  queue_length:
    type: "Object"
    object:
      metric:
        name: "queue_length"
      describedObject:
        apiVersion: "v1"
        kind: "Service"
        name: "message-queue"
      target:
        type: "Value"
        value: "100"
    description: "Scale based on message queue length"

  custom_business_metric:
    type: "External"
    external:
      metric:
        name: "active_users"
        selector:
          matchLabels:
            app: "{{APP_NAME}}"
      target:
        type: "AverageValue"
        averageValue: "1000"
    description: "Scale based on external business metric"
```

## Metrics Server Setup

```yaml
metrics_server:
  installation:
    method: "kubectl apply"
    command: |
      kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

  minikube_setup:
    command: "minikube addons enable metrics-server"
    verification: "kubectl get deployment metrics-server -n kube-system"

  verification:
    command: "kubectl top nodes"
    expected: "Node CPU and memory usage displayed"

  troubleshooting:
    issue: "metrics-server not working in Minikube"
    solution: |
      kubectl patch deployment metrics-server -n kube-system --type='json' \
        -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

## Scaling Calculation Examples

```yaml
scaling_calculations:
  cpu_based:
    current_replicas: 3
    current_cpu_utilization: 90
    target_cpu_utilization: 80
    calculation: |
      desired_replicas = ceil(current_replicas * (current_utilization / target_utilization))
      desired_replicas = ceil(3 * (90 / 80))
      desired_replicas = ceil(3 * 1.125)
      desired_replicas = 4
    result: "Scale up from 3 to 4 replicas"

  memory_based:
    current_replicas: 5
    current_memory_utilization: 60
    target_memory_utilization: 80
    calculation: |
      desired_replicas = ceil(5 * (60 / 80))
      desired_replicas = ceil(5 * 0.75)
      desired_replicas = 4
    result: "Scale down from 5 to 4 replicas"

  multiple_metrics:
    description: "When multiple metrics are configured, HPA uses the highest desired replica count"
    cpu_suggests: 4
    memory_suggests: 3
    result: "Scale to 4 replicas (max of all metrics)"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl get hpa {{HPA_NAME}}"
    description: "Verify HPA resource created"
    success_criteria: "HPA exists with targets configured"

  - command: "kubectl describe hpa {{HPA_NAME}}"
    description: "Check HPA configuration and current metrics"
    success_criteria: "Metrics are being collected"

  - command: "kubectl top pods -l app={{APP_NAME}}"
    description: "View current resource usage"
    success_criteria: "CPU and memory usage displayed"

  - command: "kubectl get hpa {{HPA_NAME}} --watch"
    description: "Monitor HPA scaling decisions"
    success_criteria: "Replicas adjust based on load"

  - command: "kubectl get events --field-selector involvedObject.name={{HPA_NAME}}"
    description: "View HPA scaling events"
    success_criteria: "Scaling events logged"
```

## Load Testing for HPA Validation

```yaml
load_testing:
  simple_load:
    description: "Generate CPU load to trigger scaling"
    command: |
      kubectl run -it --rm load-generator --image=busybox --restart=Never -- /bin/sh -c \
        "while true; do wget -q -O- http://{{SERVICE_NAME}}; done"

  apache_bench:
    description: "HTTP load testing with Apache Bench"
    command: |
      kubectl run -it --rm load-generator --image=httpd --restart=Never -- \
        ab -n 100000 -c 100 http://{{SERVICE_NAME}}/

  hey_load_test:
    description: "Modern HTTP load testing"
    command: |
      kubectl run -it --rm load-generator --image=williamyeh/hey --restart=Never -- \
        -z 5m -c 100 http://{{SERVICE_NAME}}/

  monitoring:
    watch_hpa: "kubectl get hpa {{HPA_NAME}} --watch"
    watch_pods: "kubectl get pods -l app={{APP_NAME}} --watch"
    watch_metrics: "watch -n 2 'kubectl top pods -l app={{APP_NAME}}'"
```

## Best Practices

```yaml
best_practices:
  replica_bounds:
    - "Set min_replicas >= 2 for high availability"
    - "Set max_replicas based on cluster capacity and budget"
    - "Leave headroom: max_replicas < total_cluster_capacity"

  metric_targets:
    - "CPU target: 70-80% for optimal resource usage"
    - "Memory target: 80-85% (memory is less flexible than CPU)"
    - "Avoid targets > 90% to prevent constant scaling"

  stabilization_windows:
    - "Scale-up: 0-60s (respond quickly to load)"
    - "Scale-down: 300-600s (prevent flapping)"
    - "Longer windows for production stability"

  resource_requests:
    - "Always set resource requests for HPA to work"
    - "Requests should match typical usage, not peaks"
    - "HPA calculates based on requests, not limits"

  monitoring:
    - "Monitor HPA events for scaling patterns"
    - "Alert on max replicas reached"
    - "Track scaling frequency to tune thresholds"
```

## Troubleshooting Guide

```yaml
common_issues:
  - issue: "HPA shows <unknown> for metrics"
    causes:
      - "Metrics server not installed"
      - "Resource requests not set"
      - "Pods not ready"
    diagnosis: "kubectl describe hpa {{HPA_NAME}}"
    resolution: "Install metrics-server and set resource requests"

  - issue: "HPA not scaling up"
    causes:
      - "Utilization below target"
      - "Already at max replicas"
      - "Stabilization window active"
    diagnosis: "kubectl top pods -l app={{APP_NAME}}"
    resolution: "Verify actual load and check max_replicas"

  - issue: "HPA scaling too frequently (flapping)"
    causes:
      - "Stabilization window too short"
      - "Target utilization too aggressive"
      - "Workload is bursty"
    diagnosis: "kubectl get events --field-selector involvedObject.name={{HPA_NAME}}"
    resolution: "Increase stabilization window or adjust targets"

  - issue: "Pods being killed during scale-down"
    causes:
      - "No graceful shutdown handling"
      - "terminationGracePeriodSeconds too short"
    diagnosis: "kubectl logs {{POD_NAME}}"
    resolution: "Implement graceful shutdown and increase grace period"
```

## Integration Points

- **Depends On**: `kubernetes-deployment-designer` (deployment with resource requests)
- **Next Skill**: `kubectl-ai-prompt-engineer` (AI-assisted optimization)
- **Outputs To**: Production scaling configuration

## Performance Targets

- HPA creation: < 5 seconds
- Metrics collection interval: 15 seconds (default)
- Scaling decision latency: 30-60 seconds
- Scale-up time: 1-3 minutes (including pod startup)

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
