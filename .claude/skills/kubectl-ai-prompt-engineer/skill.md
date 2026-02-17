# kubectl-ai Prompt Engineer Skill

## Skill ID
`kubectl-ai-prompt-engineer`

## Category
🤖 AI DevOps

## Responsibility
Generate kubectl-ai structured prompts for deployment, scaling, debugging, and cluster management operations using AI-assisted Kubernetes commands.

## Inputs

```yaml
inputs:
  task_type: string             # "deploy" | "scale" | "debug" | "optimize" | "troubleshoot"
  context:
    application_name: string
    namespace: string
    deployment_name: string
    error_logs: string          # Optional: for debugging
    current_state: object       # Current cluster state
  objectives: array             # Specific goals for the operation
  constraints: object           # Resource limits, policies
```

## Outputs

```yaml
outputs:
  deployment_prompt:
    prompt: string
    expected_commands: array
    validation_steps: array
  scaling_prompt:
    prompt: string
    target_replicas: integer
    expected_outcome: string
  debug_prompt:
    prompt: string
    diagnostic_commands: array
    expected_findings: string
```

## Algorithm

1. **Task Classification**
   - Identify the primary kubectl-ai task
   - Determine required Kubernetes resources
   - Assess complexity level

2. **Context Enrichment**
   - Gather current cluster state
   - Collect relevant resource information
   - Identify dependencies

3. **Prompt Construction**
   - Use natural language for kubectl-ai
   - Include specific constraints
   - Define success criteria
   - Add validation steps

4. **Command Generation**
   - Generate kubectl-ai prompts
   - Provide fallback kubectl commands
   - Include verification steps

## Prompt Templates

### Deployment Prompt

```yaml
deployment_prompt:
  template: |
    Deploy {{APPLICATION_NAME}} to Kubernetes cluster with the following requirements:

    **Application Details:**
    - Image: {{IMAGE}}:{{TAG}}
    - Port: {{PORT}}
    - Replicas: {{REPLICAS}}
    - Namespace: {{NAMESPACE}}

    **Resource Requirements:**
    - CPU Request: {{CPU_REQUEST}}
    - Memory Request: {{MEMORY_REQUEST}}
    - CPU Limit: {{CPU_LIMIT}}
    - Memory Limit: {{MEMORY_LIMIT}}

    **Configuration:**
    - Environment: {{ENVIRONMENT}}
    - Health Check Path: {{HEALTH_PATH}}
    - Service Type: {{SERVICE_TYPE}}

    **Requirements:**
    1. Create deployment with rolling update strategy
    2. Configure liveness and readiness probes
    3. Create ClusterIP service
    4. Apply resource limits
    5. Use non-root security context

    Please generate the necessary Kubernetes manifests and apply them.

  kubectl_ai_command: |
    kubectl ai "{{PROMPT}}"

  expected_commands:
    - "kubectl create deployment {{APP_NAME}} --image={{IMAGE}}:{{TAG}}"
    - "kubectl set resources deployment {{APP_NAME}} --requests=cpu={{CPU_REQUEST}},memory={{MEMORY_REQUEST}}"
    - "kubectl expose deployment {{APP_NAME}} --port={{PORT}} --type={{SERVICE_TYPE}}"

  validation_steps:
    - "kubectl get deployment {{APP_NAME}}"
    - "kubectl get pods -l app={{APP_NAME}}"
    - "kubectl get service {{APP_NAME}}"
```

### Scaling Prompt

```yaml
scaling_prompt:
  template: |
    Scale the {{DEPLOYMENT_NAME}} deployment in {{NAMESPACE}} namespace.

    **Current State:**
    - Current Replicas: {{CURRENT_REPLICAS}}
    - Current CPU Usage: {{CPU_USAGE}}%
    - Current Memory Usage: {{MEMORY_USAGE}}%

    **Scaling Objective:**
    {{#if SCALE_UP}}
    Scale up to handle increased load:
    - Target Replicas: {{TARGET_REPLICAS}}
    - Reason: {{SCALE_REASON}}
    {{else}}
    Scale down to optimize resources:
    - Target Replicas: {{TARGET_REPLICAS}}
    - Reason: {{SCALE_REASON}}
    {{/if}}

    **Constraints:**
    - Min Replicas: {{MIN_REPLICAS}}
    - Max Replicas: {{MAX_REPLICAS}}
    - Ensure zero downtime

    Please scale the deployment safely with proper validation.

  kubectl_ai_command: |
    kubectl ai "{{PROMPT}}"

  expected_commands:
    - "kubectl scale deployment {{DEPLOYMENT_NAME}} --replicas={{TARGET_REPLICAS}}"
    - "kubectl rollout status deployment {{DEPLOYMENT_NAME}}"

  validation_steps:
    - "kubectl get deployment {{DEPLOYMENT_NAME}}"
    - "kubectl get pods -l app={{APP_NAME}} --watch"
```

### Debug Prompt

```yaml
debug_prompt:
  template: |
    Debug the {{APPLICATION_NAME}} application in {{NAMESPACE}} namespace.

    **Problem Description:**
    {{PROBLEM_DESCRIPTION}}

    **Observed Symptoms:**
    {{#each SYMPTOMS}}
    - {{this}}
    {{/each}}

    **Error Logs:**
    ```
    {{ERROR_LOGS}}
    ```

    **Current State:**
    - Deployment Status: {{DEPLOYMENT_STATUS}}
    - Pod Status: {{POD_STATUS}}
    - Recent Events: {{RECENT_EVENTS}}

    **Diagnostic Requirements:**
    1. Identify root cause of the issue
    2. Check pod logs for errors
    3. Verify resource availability
    4. Check service endpoints
    5. Validate configuration

    Please diagnose the issue and suggest remediation steps.

  kubectl_ai_command: |
    kubectl ai "{{PROMPT}}"

  diagnostic_commands:
    - "kubectl describe deployment {{DEPLOYMENT_NAME}}"
    - "kubectl get pods -l app={{APP_NAME}}"
    - "kubectl logs -l app={{APP_NAME}} --tail=100"
    - "kubectl get events --field-selector involvedObject.name={{DEPLOYMENT_NAME}}"
    - "kubectl top pods -l app={{APP_NAME}}"

  expected_findings:
    - "Root cause identification"
    - "Specific error messages"
    - "Resource constraints"
    - "Configuration issues"
    - "Remediation steps"
```

### Optimization Prompt

```yaml
optimization_prompt:
  template: |
    Optimize the {{APPLICATION_NAME}} deployment for better performance and resource efficiency.

    **Current Configuration:**
    - Replicas: {{CURRENT_REPLICAS}}
    - CPU Request: {{CPU_REQUEST}}
    - Memory Request: {{MEMORY_REQUEST}}
    - CPU Limit: {{CPU_LIMIT}}
    - Memory Limit: {{MEMORY_LIMIT}}

    **Current Metrics:**
    - Average CPU Usage: {{AVG_CPU_USAGE}}%
    - Average Memory Usage: {{AVG_MEMORY_USAGE}}%
    - P95 Response Time: {{P95_RESPONSE_TIME}}ms
    - Error Rate: {{ERROR_RATE}}%

    **Optimization Goals:**
    {{#each GOALS}}
    - {{this}}
    {{/each}}

    **Constraints:**
    - Budget: {{BUDGET_CONSTRAINT}}
    - SLA: {{SLA_REQUIREMENT}}
    - Availability: {{AVAILABILITY_TARGET}}

    Please analyze and suggest optimizations for:
    1. Resource allocation
    2. Replica count
    3. Autoscaling configuration
    4. Pod disruption budget
    5. Deployment strategy

  kubectl_ai_command: |
    kubectl ai "{{PROMPT}}"

  expected_recommendations:
    - "Adjusted resource requests/limits"
    - "HPA configuration"
    - "Deployment strategy improvements"
    - "Cost optimization suggestions"
```

### Troubleshooting Prompt

```yaml
troubleshooting_prompt:
  template: |
    Troubleshoot {{ISSUE_TYPE}} issue with {{APPLICATION_NAME}}.

    **Issue Details:**
    - Type: {{ISSUE_TYPE}}
    - Severity: {{SEVERITY}}
    - Started: {{START_TIME}}
    - Affected Users: {{AFFECTED_USERS}}

    **Symptoms:**
    {{#each SYMPTOMS}}
    - {{this}}
    {{/each}}

    **Recent Changes:**
    {{#each RECENT_CHANGES}}
    - {{this.timestamp}}: {{this.description}}
    {{/each}}

    **Investigation Steps Needed:**
    1. Check pod health and status
    2. Review application logs
    3. Verify service connectivity
    4. Check resource utilization
    5. Review recent deployments
    6. Validate configuration

    Please investigate and provide:
    - Root cause analysis
    - Impact assessment
    - Remediation steps
    - Prevention recommendations

  kubectl_ai_command: |
    kubectl ai "{{PROMPT}}"

  investigation_commands:
    - "kubectl get all -l app={{APP_NAME}}"
    - "kubectl describe pods -l app={{APP_NAME}}"
    - "kubectl logs -l app={{APP_NAME}} --since=1h"
    - "kubectl get events --sort-by='.lastTimestamp'"
    - "kubectl top nodes"
    - "kubectl top pods -l app={{APP_NAME}}"
```

## Common Use Cases

```yaml
use_cases:
  crashloopbackoff:
    prompt: |
      The {{APP_NAME}} pods are in CrashLoopBackOff state.
      Diagnose why the pods are crashing and suggest fixes.
      Check logs, resource limits, and configuration.

  high_memory_usage:
    prompt: |
      The {{APP_NAME}} deployment is experiencing high memory usage (>90%).
      Analyze memory consumption patterns and suggest optimizations.
      Consider memory leaks, cache size, and resource limits.

  slow_response_time:
    prompt: |
      The {{APP_NAME}} service has slow response times (>2s).
      Investigate performance bottlenecks and suggest improvements.
      Check pod resources, database connections, and external dependencies.

  failed_deployment:
    prompt: |
      The latest deployment of {{APP_NAME}} failed to roll out.
      Identify why the rollout failed and how to fix it.
      Check image pull errors, health probes, and resource availability.

  service_unreachable:
    prompt: |
      The {{APP_NAME}} service is unreachable from other pods.
      Debug service connectivity and DNS resolution.
      Verify service selectors, endpoints, and network policies.
```

## kubectl-ai Best Practices

```yaml
best_practices:
  prompt_structure:
    - "Start with clear objective"
    - "Provide complete context"
    - "Specify constraints explicitly"
    - "Define success criteria"
    - "Request actionable outputs"

  context_inclusion:
    - "Application name and namespace"
    - "Current state and metrics"
    - "Error messages and logs"
    - "Recent changes"
    - "Resource constraints"

  output_specification:
    - "Request specific commands"
    - "Ask for explanations"
    - "Require validation steps"
    - "Specify output format"

  validation:
    - "Include verification commands"
    - "Define expected outcomes"
    - "Specify rollback procedures"
```

## Integration with kubectl-ai

```yaml
kubectl_ai_integration:
  installation:
    method: "kubectl plugin"
    command: "kubectl krew install ai"
    verification: "kubectl ai --version"

  configuration:
    api_key: "Set OPENAI_API_KEY environment variable"
    model: "gpt-4 (recommended for complex operations)"

  usage_pattern:
    basic: 'kubectl ai "deploy nginx with 3 replicas"'
    with_context: 'kubectl ai "scale deployment nginx based on current load"'
    complex: 'kubectl ai "optimize resource allocation for all deployments in production namespace"'

  response_handling:
    - "Review suggested commands before execution"
    - "Validate against cluster policies"
    - "Test in non-production first"
    - "Monitor execution results"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl ai --version"
    description: "Verify kubectl-ai is installed"
    success_criteria: "Version displayed"

  - command: 'kubectl ai "list all deployments"'
    description: "Test basic kubectl-ai functionality"
    success_criteria: "Deployments listed"

  - command: 'kubectl ai "{{GENERATED_PROMPT}}"'
    description: "Execute generated prompt"
    success_criteria: "Expected commands generated"
```

## Error Handling

```yaml
error_scenarios:
  - error: "kubectl-ai not installed"
    detection: "kubectl: 'ai' is not a kubectl command"
    resolution: "Install kubectl-ai plugin via krew"

  - error: "API key not configured"
    detection: "OPENAI_API_KEY not set"
    resolution: "Set environment variable with OpenAI API key"

  - error: "Prompt too vague"
    detection: "kubectl-ai requests more context"
    resolution: "Enrich prompt with specific details"

  - error: "Generated commands unsafe"
    detection: "Commands include destructive operations"
    resolution: "Review and modify commands before execution"
```

## Integration Points

- **Depends On**: Kubernetes cluster access
- **Next Skill**: `kagent-diagnostics` (cluster health analysis)
- **Outputs To**: Kubernetes operations automation

## Performance Targets

- Prompt generation: < 1 second
- kubectl-ai response time: 5-15 seconds
- Command execution: Varies by operation

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
