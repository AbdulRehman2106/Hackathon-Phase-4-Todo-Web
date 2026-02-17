# Kagent Diagnostics Skill

## Skill ID
`kagent-diagnostics`

## Category
🤖 AI DevOps

## Responsibility
Generate Kagent prompts for cluster health analysis, resource optimization suggestions, and intelligent Kubernetes diagnostics using AI-powered cluster insights.

## Inputs

```yaml
inputs:
  diagnostic_type: string       # "health" | "optimization" | "troubleshooting" | "capacity"
  cluster_context:
    cluster_name: string
    namespace: string           # Optional: specific namespace or "all"
    node_count: integer
    total_resources: object
  focus_areas: array            # ["pods", "nodes", "services", "resources", "networking"]
  time_range: string            # "1h" | "24h" | "7d" | "30d"
  severity_filter: string       # "all" | "critical" | "warning" | "info"
```

## Outputs

```yaml
outputs:
  health_analysis_prompt:
    prompt: string
    analysis_scope: array
    expected_insights: array
  optimization_prompt:
    prompt: string
    optimization_targets: array
    expected_recommendations: array
```

## Algorithm

1. **Diagnostic Scope Definition**
   - Identify cluster components to analyze
   - Determine time range for historical data
   - Set severity thresholds

2. **Context Gathering**
   - Collect cluster state information
   - Gather resource utilization metrics
   - Identify recent events and changes

3. **Prompt Construction**
   - Build comprehensive diagnostic prompt
   - Include relevant metrics and logs
   - Specify analysis objectives
   - Define output format

4. **Analysis Execution**
   - Execute Kagent with generated prompt
   - Parse AI-generated insights
   - Prioritize recommendations
   - Generate action items

## Prompt Templates

### Cluster Health Analysis Prompt

```yaml
health_analysis_prompt:
  template: |
    Perform comprehensive health analysis of Kubernetes cluster: {{CLUSTER_NAME}}

    **Cluster Overview:**
    - Nodes: {{NODE_COUNT}}
    - Namespaces: {{NAMESPACE_COUNT}}
    - Total Pods: {{POD_COUNT}}
    - Cluster Version: {{K8S_VERSION}}

    **Analysis Scope:**
    {{#each FOCUS_AREAS}}
    - {{this}}
    {{/each}}

    **Time Range:** {{TIME_RANGE}}

    **Current Metrics:**
    - CPU Utilization: {{CPU_UTILIZATION}}%
    - Memory Utilization: {{MEMORY_UTILIZATION}}%
    - Disk Utilization: {{DISK_UTILIZATION}}%
    - Network I/O: {{NETWORK_IO}}

    **Recent Events (Last {{TIME_RANGE}}):**
    {{#each RECENT_EVENTS}}
    - [{{this.type}}] {{this.message}} ({{this.count}} occurrences)
    {{/each}}

    **Analysis Requirements:**
    1. Assess overall cluster health
    2. Identify potential issues or bottlenecks
    3. Check for resource constraints
    4. Verify pod and node health
    5. Analyze event patterns
    6. Detect configuration issues
    7. Evaluate security posture

    **Output Format:**
    - Health Score (0-100)
    - Critical Issues (immediate attention)
    - Warnings (should address soon)
    - Recommendations (optimization opportunities)
    - Trend Analysis (resource usage patterns)

  kagent_command: |
    kagent analyze cluster --prompt "{{PROMPT}}"

  expected_insights:
    - "Overall cluster health score"
    - "Critical issues requiring immediate action"
    - "Resource bottlenecks"
    - "Pod health status"
    - "Node capacity analysis"
    - "Security vulnerabilities"
    - "Configuration recommendations"
```

### Resource Optimization Prompt

```yaml
optimization_prompt:
  template: |
    Analyze and optimize resource allocation for Kubernetes cluster: {{CLUSTER_NAME}}

    **Current Resource Allocation:**
    - Total CPU: {{TOTAL_CPU}} cores
    - Total Memory: {{TOTAL_MEMORY}} GB
    - CPU Requested: {{CPU_REQUESTED}} ({{CPU_REQUESTED_PERCENT}}%)
    - Memory Requested: {{MEMORY_REQUESTED}} ({{MEMORY_REQUESTED_PERCENT}}%)
    - CPU Used: {{CPU_USED}} ({{CPU_USED_PERCENT}}%)
    - Memory Used: {{MEMORY_USED}} ({{MEMORY_USED_PERCENT}}%)

    **Workload Analysis:**
    {{#each WORKLOADS}}
    - {{this.name}}:
      - Replicas: {{this.replicas}}
      - CPU Request: {{this.cpu_request}}
      - Memory Request: {{this.memory_request}}
      - Actual CPU Usage: {{this.cpu_usage}}
      - Actual Memory Usage: {{this.memory_usage}}
      - Over-provisioned: {{this.over_provisioned}}
      - Under-provisioned: {{this.under_provisioned}}
    {{/each}}

    **Optimization Goals:**
    {{#each GOALS}}
    - {{this}}
    {{/each}}

    **Constraints:**
    - Budget: {{BUDGET_CONSTRAINT}}
    - SLA Requirements: {{SLA_REQUIREMENTS}}
    - Availability Target: {{AVAILABILITY_TARGET}}

    **Analysis Requirements:**
    1. Identify over-provisioned workloads
    2. Identify under-provisioned workloads
    3. Suggest optimal resource requests/limits
    4. Recommend autoscaling configurations
    5. Identify cost optimization opportunities
    6. Suggest node pool optimizations
    7. Evaluate pod density improvements

    **Output Format:**
    - Cost Savings Potential
    - Resource Reallocation Recommendations
    - Autoscaling Suggestions
    - Node Pool Optimization
    - Implementation Priority

  kagent_command: |
    kagent optimize resources --prompt "{{PROMPT}}"

  expected_recommendations:
    - "Specific resource adjustments per workload"
    - "Cost savings estimates"
    - "HPA configuration recommendations"
    - "Node pool sizing suggestions"
    - "Pod density improvements"
```

### Troubleshooting Prompt

```yaml
troubleshooting_prompt:
  template: |
    Troubleshoot issues in Kubernetes cluster: {{CLUSTER_NAME}}

    **Problem Description:**
    {{PROBLEM_DESCRIPTION}}

    **Affected Components:**
    {{#each AFFECTED_COMPONENTS}}
    - {{this.type}}: {{this.name}} (Namespace: {{this.namespace}})
    {{/each}}

    **Symptoms:**
    {{#each SYMPTOMS}}
    - {{this}}
    {{/each}}

    **Error Logs:**
    ```
    {{ERROR_LOGS}}
    ```

    **Recent Changes:**
    {{#each RECENT_CHANGES}}
    - {{this.timestamp}}: {{this.description}}
    {{/each}}

    **Current State:**
    - Pod Status: {{POD_STATUS}}
    - Service Status: {{SERVICE_STATUS}}
    - Node Status: {{NODE_STATUS}}
    - Events: {{EVENT_COUNT}} events in last hour

    **Investigation Requirements:**
    1. Identify root cause of the issue
    2. Analyze error patterns
    3. Check resource availability
    4. Verify network connectivity
    5. Validate configurations
    6. Review recent deployments
    7. Check for known issues

    **Output Format:**
    - Root Cause Analysis
    - Impact Assessment
    - Remediation Steps (prioritized)
    - Prevention Recommendations
    - Monitoring Improvements

  kagent_command: |
    kagent troubleshoot --prompt "{{PROMPT}}"

  expected_findings:
    - "Root cause identification"
    - "Contributing factors"
    - "Step-by-step remediation"
    - "Prevention strategies"
    - "Monitoring recommendations"
```

### Capacity Planning Prompt

```yaml
capacity_planning_prompt:
  template: |
    Perform capacity planning analysis for Kubernetes cluster: {{CLUSTER_NAME}}

    **Current Capacity:**
    - Nodes: {{NODE_COUNT}}
    - Total CPU: {{TOTAL_CPU}} cores
    - Total Memory: {{TOTAL_MEMORY}} GB
    - Total Storage: {{TOTAL_STORAGE}} GB

    **Current Utilization:**
    - CPU: {{CPU_UTILIZATION}}%
    - Memory: {{MEMORY_UTILIZATION}}%
    - Storage: {{STORAGE_UTILIZATION}}%
    - Pod Count: {{POD_COUNT}} / {{MAX_PODS}}

    **Growth Trends (Last {{TIME_RANGE}}):**
    - CPU Growth: {{CPU_GROWTH}}% per month
    - Memory Growth: {{MEMORY_GROWTH}}% per month
    - Pod Growth: {{POD_GROWTH}}% per month
    - Storage Growth: {{STORAGE_GROWTH}}% per month

    **Planned Workloads:**
    {{#each PLANNED_WORKLOADS}}
    - {{this.name}}: {{this.replicas}} replicas, {{this.cpu_request}} CPU, {{this.memory_request}} memory
    {{/each}}

    **Planning Horizon:** {{PLANNING_HORIZON}}

    **Analysis Requirements:**
    1. Project resource needs for planning horizon
    2. Identify capacity constraints
    3. Recommend node additions/removals
    4. Suggest cluster scaling strategy
    5. Estimate costs for projected capacity
    6. Identify optimization opportunities
    7. Plan for peak load scenarios

    **Output Format:**
    - Capacity Forecast
    - Scaling Recommendations
    - Cost Projections
    - Risk Assessment
    - Implementation Timeline

  kagent_command: |
    kagent plan capacity --prompt "{{PROMPT}}"

  expected_recommendations:
    - "Node scaling timeline"
    - "Resource allocation strategy"
    - "Cost projections"
    - "Risk mitigation plans"
```

## Common Diagnostic Scenarios

```yaml
scenarios:
  pod_failures:
    prompt: |
      Analyze pod failures in {{NAMESPACE}} namespace.
      {{FAILURE_COUNT}} pods have failed in the last {{TIME_RANGE}}.
      Identify common failure patterns and root causes.

  resource_exhaustion:
    prompt: |
      Cluster is experiencing resource exhaustion.
      CPU utilization: {{CPU_UTIL}}%, Memory: {{MEM_UTIL}}%.
      Identify which workloads are consuming most resources and suggest optimizations.

  network_issues:
    prompt: |
      Services are experiencing intermittent connectivity issues.
      Analyze network policies, service endpoints, and DNS resolution.
      Identify network bottlenecks and misconfigurations.

  slow_performance:
    prompt: |
      Applications are experiencing degraded performance.
      Analyze resource contention, I/O bottlenecks, and scheduling issues.
      Suggest performance optimization strategies.

  cost_optimization:
    prompt: |
      Current monthly cluster cost: ${{CURRENT_COST}}.
      Analyze resource utilization and identify cost optimization opportunities.
      Target: Reduce costs by {{TARGET_REDUCTION}}% without impacting performance.
```

## Kagent Integration

```yaml
kagent_integration:
  installation:
    method: "kubectl plugin or standalone CLI"
    command: "kubectl krew install kagent"
    verification: "kagent --version"

  configuration:
    api_key: "Set KAGENT_API_KEY environment variable"
    cluster_access: "Requires kubectl cluster access"
    permissions: "Read access to cluster resources"

  usage_patterns:
    basic: "kagent analyze cluster"
    with_namespace: "kagent analyze cluster --namespace production"
    with_focus: "kagent analyze cluster --focus pods,nodes"
    optimization: "kagent optimize resources --namespace production"

  output_formats:
    json: "kagent analyze cluster --output json"
    yaml: "kagent analyze cluster --output yaml"
    table: "kagent analyze cluster --output table"
    markdown: "kagent analyze cluster --output markdown"
```

## Analysis Metrics

```yaml
health_metrics:
  cluster_health_score:
    range: "0-100"
    thresholds:
      critical: "< 60"
      warning: "60-80"
      healthy: "> 80"

  resource_efficiency:
    calculation: "(actual_usage / requested_resources) * 100"
    optimal_range: "70-85%"

  pod_health_ratio:
    calculation: "running_pods / total_pods"
    target: "> 95%"

  node_availability:
    calculation: "ready_nodes / total_nodes"
    target: "100%"

  event_severity_distribution:
    critical: "count of critical events"
    warning: "count of warning events"
    info: "count of info events"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kagent --version"
    description: "Verify Kagent is installed"
    success_criteria: "Version displayed"

  - command: "kagent analyze cluster --dry-run"
    description: "Test Kagent connectivity"
    success_criteria: "Cluster accessible"

  - command: "kagent analyze cluster --prompt '{{GENERATED_PROMPT}}'"
    description: "Execute health analysis"
    success_criteria: "Analysis report generated"

  - command: "kagent optimize resources --namespace production"
    description: "Get optimization recommendations"
    success_criteria: "Recommendations provided"
```

## Best Practices

```yaml
best_practices:
  prompt_design:
    - "Be specific about analysis scope"
    - "Include relevant time ranges"
    - "Specify output format requirements"
    - "Define success criteria"

  analysis_frequency:
    health_checks: "Daily or on-demand"
    optimization_reviews: "Weekly"
    capacity_planning: "Monthly"
    troubleshooting: "As needed"

  action_prioritization:
    critical: "Address immediately"
    high: "Within 24 hours"
    medium: "Within 1 week"
    low: "Next maintenance window"

  monitoring_integration:
    - "Integrate with existing monitoring tools"
    - "Set up alerts for critical findings"
    - "Track optimization implementation"
    - "Measure improvement metrics"
```

## Error Handling

```yaml
error_scenarios:
  - error: "Kagent not installed"
    detection: "kagent: command not found"
    resolution: "Install Kagent via kubectl krew or standalone"

  - error: "Insufficient permissions"
    detection: "Error: forbidden"
    resolution: "Grant read access to cluster resources"

  - error: "API key not configured"
    detection: "KAGENT_API_KEY not set"
    resolution: "Set environment variable with Kagent API key"

  - error: "Cluster unreachable"
    detection: "Unable to connect to cluster"
    resolution: "Verify kubectl context and cluster connectivity"
```

## Integration Points

- **Depends On**: `kubectl-ai-prompt-engineer` (AI-assisted operations)
- **Next Skill**: `cohere-api-integrator` (AI chatbot integration)
- **Outputs To**: Cluster optimization and monitoring systems

## Performance Targets

- Prompt generation: < 2 seconds
- Kagent analysis time: 30-120 seconds (depends on cluster size)
- Report generation: < 10 seconds

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
