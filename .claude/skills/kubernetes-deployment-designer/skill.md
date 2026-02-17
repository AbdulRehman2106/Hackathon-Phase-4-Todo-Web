# Kubernetes Deployment Designer Skill

## Skill ID
`kubernetes-deployment-designer`

## Category
☸️ Kubernetes

## Responsibility
Define replica sets, configure resource limits, establish liveness & readiness probes, and specify service types for Kubernetes deployments.

## Inputs

```yaml
inputs:
  application:
    name: string
    image: string
    tag: string
    port: integer
  deployment_config:
    replicas: integer
    strategy: string            # "RollingUpdate" | "Recreate"
    max_surge: string           # e.g., "25%"
    max_unavailable: string     # e.g., "25%"
  resources:
    requests:
      cpu: string
      memory: string
    limits:
      cpu: string
      memory: string
  probes:
    liveness:
      enabled: boolean
      path: string
      initial_delay: integer
      period: integer
      timeout: integer
      failure_threshold: integer
    readiness:
      enabled: boolean
      path: string
      initial_delay: integer
      period: integer
  service:
    type: string                # "ClusterIP" | "NodePort" | "LoadBalancer"
    port: integer
    target_port: integer
  environment: string           # "development" | "staging" | "production"
```

## Outputs

```yaml
outputs:
  deployment_config:
    manifest: string            # YAML deployment manifest
    replica_strategy: object
    rollout_config: object
  service_config:
    manifest: string            # YAML service manifest
    service_type: string
    endpoints: array
  probe_config:
    liveness_probe: object
    readiness_probe: object
    startup_probe: object
```

## Algorithm

1. **Replica Strategy Design**
   - Determine replica count based on environment
   - Configure rolling update strategy
   - Set surge and unavailable parameters
   - Define pod disruption budget

2. **Resource Allocation**
   - Calculate resource requests (guaranteed)
   - Set resource limits (maximum)
   - Apply QoS class (Guaranteed/Burstable/BestEffort)
   - Consider node capacity

3. **Probe Configuration**
   - Configure liveness probe (restart unhealthy pods)
   - Configure readiness probe (traffic routing)
   - Configure startup probe (slow-starting apps)
   - Set appropriate timeouts and thresholds

4. **Service Design**
   - Select service type based on exposure needs
   - Configure port mappings
   - Set session affinity if needed
   - Define load balancing strategy

## Deployment Manifest Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{APP_NAME}}
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
    version: {{VERSION}}
    environment: {{ENVIRONMENT}}
  annotations:
    deployment.kubernetes.io/revision: "1"
spec:
  replicas: {{REPLICAS}}
  strategy:
    type: {{STRATEGY_TYPE}}
    rollingUpdate:
      maxSurge: {{MAX_SURGE}}
      maxUnavailable: {{MAX_UNAVAILABLE}}
  selector:
    matchLabels:
      app: {{APP_NAME}}
  template:
    metadata:
      labels:
        app: {{APP_NAME}}
        version: {{VERSION}}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "{{PORT}}"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: {{APP_NAME}}-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: {{APP_NAME}}
        image: {{IMAGE}}:{{TAG}}
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: {{PORT}}
          protocol: TCP
        env:
        - name: NODE_ENV
          value: "{{ENVIRONMENT}}"
        - name: PORT
          value: "{{PORT}}"
        resources:
          requests:
            cpu: {{CPU_REQUEST}}
            memory: {{MEMORY_REQUEST}}
          limits:
            cpu: {{CPU_LIMIT}}
            memory: {{MEMORY_LIMIT}}
        livenessProbe:
          httpGet:
            path: {{LIVENESS_PATH}}
            port: http
            scheme: HTTP
          initialDelaySeconds: {{LIVENESS_INITIAL_DELAY}}
          periodSeconds: {{LIVENESS_PERIOD}}
          timeoutSeconds: {{LIVENESS_TIMEOUT}}
          successThreshold: 1
          failureThreshold: {{LIVENESS_FAILURE_THRESHOLD}}
        readinessProbe:
          httpGet:
            path: {{READINESS_PATH}}
            port: http
            scheme: HTTP
          initialDelaySeconds: {{READINESS_INITIAL_DELAY}}
          periodSeconds: {{READINESS_PERIOD}}
          timeoutSeconds: {{READINESS_TIMEOUT}}
          successThreshold: 1
          failureThreshold: {{READINESS_FAILURE_THRESHOLD}}
        startupProbe:
          httpGet:
            path: {{READINESS_PATH}}
            port: http
          initialDelaySeconds: 0
          periodSeconds: 10
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 30
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/.cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
```

## Service Manifest Template

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{APP_NAME}}
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
spec:
  type: {{SERVICE_TYPE}}
  selector:
    app: {{APP_NAME}}
  ports:
  - name: http
    protocol: TCP
    port: {{SERVICE_PORT}}
    targetPort: {{TARGET_PORT}}
    {{#if NODE_PORT}}
    nodePort: {{NODE_PORT}}
    {{/if}}
  sessionAffinity: None
```

## Environment-Specific Configurations

```yaml
development:
  replicas: 1
  resources:
    requests:
      cpu: "100m"
      memory: "128Mi"
    limits:
      cpu: "500m"
      memory: "512Mi"
  probes:
    liveness:
      initial_delay: 10
      period: 30
      timeout: 5
      failure_threshold: 3
    readiness:
      initial_delay: 5
      period: 10
      timeout: 3
      failure_threshold: 3
  service:
    type: "NodePort"

staging:
  replicas: 2
  resources:
    requests:
      cpu: "250m"
      memory: "256Mi"
    limits:
      cpu: "1000m"
      memory: "1Gi"
  probes:
    liveness:
      initial_delay: 30
      period: 20
      timeout: 5
      failure_threshold: 3
    readiness:
      initial_delay: 10
      period: 10
      timeout: 3
      failure_threshold: 3
  service:
    type: "ClusterIP"

production:
  replicas: 3
  resources:
    requests:
      cpu: "500m"
      memory: "512Mi"
    limits:
      cpu: "2000m"
      memory: "2Gi"
  probes:
    liveness:
      initial_delay: 60
      period: 20
      timeout: 5
      failure_threshold: 3
    readiness:
      initial_delay: 30
      period: 10
      timeout: 3
      failure_threshold: 3
  service:
    type: "ClusterIP"
  pod_disruption_budget:
    min_available: 1
```

## Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{APP_NAME}}-pdb
  namespace: {{NAMESPACE}}
spec:
  minAvailable: {{MIN_AVAILABLE}}
  selector:
    matchLabels:
      app: {{APP_NAME}}
```

## Resource QoS Classes

```yaml
qos_classes:
  guaranteed:
    description: "Highest priority, requests = limits"
    configuration:
      resources:
        requests:
          cpu: "1000m"
          memory: "1Gi"
        limits:
          cpu: "1000m"
          memory: "1Gi"
    use_case: "Critical production workloads"

  burstable:
    description: "Medium priority, requests < limits"
    configuration:
      resources:
        requests:
          cpu: "500m"
          memory: "512Mi"
        limits:
          cpu: "2000m"
          memory: "2Gi"
    use_case: "Most production workloads"

  best_effort:
    description: "Lowest priority, no requests/limits"
    configuration:
      resources: {}
    use_case: "Development only, not recommended"
```

## Probe Configuration Best Practices

```yaml
probe_guidelines:
  liveness_probe:
    purpose: "Detect and restart unhealthy containers"
    recommendations:
      - "Use longer initial delay for slow-starting apps"
      - "Set failure threshold to 3-5 to avoid false positives"
      - "Check critical dependencies (DB, cache)"
      - "Return 200 if app can recover, 500 if restart needed"
    example_endpoint: "/health/live"

  readiness_probe:
    purpose: "Control traffic routing to healthy pods"
    recommendations:
      - "Use shorter initial delay than liveness"
      - "Check all dependencies (DB, external APIs)"
      - "Return 200 when ready to serve traffic"
      - "Return 503 when temporarily unavailable"
    example_endpoint: "/health/ready"

  startup_probe:
    purpose: "Handle slow-starting applications"
    recommendations:
      - "Use for apps with long initialization"
      - "Disable liveness checks until startup succeeds"
      - "Set high failure threshold (30+)"
      - "Use same endpoint as readiness"
    example_endpoint: "/health/ready"
```

## Service Type Selection Guide

```yaml
service_types:
  ClusterIP:
    description: "Internal cluster access only"
    use_cases:
      - "Backend services"
      - "Databases"
      - "Internal APIs"
    accessibility: "Within cluster only"
    example: |
      type: ClusterIP
      port: 80

  NodePort:
    description: "Expose on each node's IP at a static port"
    use_cases:
      - "Development/testing"
      - "Minikube local access"
      - "Direct node access needed"
    accessibility: "External via <NodeIP>:<NodePort>"
    port_range: "30000-32767"
    example: |
      type: NodePort
      port: 80
      nodePort: 30080

  LoadBalancer:
    description: "Cloud provider load balancer"
    use_cases:
      - "Production external services"
      - "Public APIs"
      - "Web applications"
    accessibility: "External via cloud LB"
    example: |
      type: LoadBalancer
      port: 80
```

## Deployment Strategy Comparison

```yaml
strategies:
  RollingUpdate:
    description: "Gradually replace old pods with new ones"
    advantages:
      - "Zero downtime"
      - "Gradual rollout"
      - "Easy rollback"
    disadvantages:
      - "Temporary version mix"
      - "Slower deployment"
    configuration:
      maxSurge: "25%"        # Max pods above desired count
      maxUnavailable: "25%"  # Max pods unavailable during update
    use_case: "Most production deployments"

  Recreate:
    description: "Terminate all old pods before creating new ones"
    advantages:
      - "Simple"
      - "No version mixing"
      - "Fast for small deployments"
    disadvantages:
      - "Downtime during update"
      - "Not suitable for production"
    configuration: {}
    use_case: "Development, stateful apps requiring clean state"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl apply --dry-run=client -f deployment.yaml"
    description: "Validate deployment manifest syntax"
    success_criteria: "No errors"

  - command: "kubectl apply -f deployment.yaml"
    description: "Apply deployment to cluster"
    success_criteria: "deployment.apps/{{APP_NAME}} created"

  - command: "kubectl rollout status deployment/{{APP_NAME}}"
    description: "Wait for rollout to complete"
    success_criteria: "successfully rolled out"

  - command: "kubectl get pods -l app={{APP_NAME}}"
    description: "Verify pods are running"
    success_criteria: "All pods in Running state"

  - command: "kubectl describe deployment {{APP_NAME}}"
    description: "Check deployment details"
    success_criteria: "Desired replicas match available replicas"

  - command: "kubectl logs -l app={{APP_NAME}} --tail=50"
    description: "Check application logs"
    success_criteria: "No error messages"
```

## Troubleshooting Guide

```yaml
common_issues:
  - issue: "Pods stuck in Pending"
    causes:
      - "Insufficient cluster resources"
      - "Node selector mismatch"
      - "PVC not bound"
    diagnosis: "kubectl describe pod {{POD_NAME}}"
    resolution: "Adjust resource requests or add nodes"

  - issue: "Pods in CrashLoopBackOff"
    causes:
      - "Application error"
      - "Missing dependencies"
      - "Incorrect configuration"
    diagnosis: "kubectl logs {{POD_NAME}}"
    resolution: "Fix application code or configuration"

  - issue: "Readiness probe failing"
    causes:
      - "App not fully initialized"
      - "Dependency unavailable"
      - "Incorrect probe configuration"
    diagnosis: "kubectl describe pod {{POD_NAME}}"
    resolution: "Increase initial delay or fix dependencies"

  - issue: "Service not accessible"
    causes:
      - "Incorrect selector labels"
      - "Port mismatch"
      - "Network policy blocking"
    diagnosis: "kubectl get endpoints {{SERVICE_NAME}}"
    resolution: "Verify labels and port configuration"
```

## Integration Points

- **Depends On**: `helm-chart-generator` (chart structure)
- **Next Skill**: `ingress-configurator` (external access)
- **Outputs To**: Kubernetes cluster deployment

## Performance Targets

- Manifest generation: < 2 seconds
- Deployment rollout: < 2 minutes
- Pod startup: < 30 seconds

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
