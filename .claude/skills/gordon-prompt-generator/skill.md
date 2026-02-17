# Gordon Prompt Generator Skill

## Skill ID
`gordon-prompt-generator`

## Category
🐳 Containerization

## Responsibility
Generate structured prompts for Docker AI (Gordon) to debug container failures, optimize image build processes, and provide intelligent Docker assistance.

## Inputs

```yaml
inputs:
  task_type: string             # "build" | "debug" | "optimize" | "security"
  context:
    dockerfile_path: string
    image_name: string
    error_logs: string          # Optional: error output
    build_history: array        # Previous build attempts
    performance_metrics: object # Image size, build time, etc.
  optimization_goals: array     # ["size", "speed", "security", "layers"]
  constraints: object           # Resource limits, base image restrictions
```

## Outputs

```yaml
outputs:
  gordon_build_prompt:
    prompt: string
    expected_actions: array
    validation_criteria: string
  gordon_debug_prompt:
    prompt: string
    context_provided: object
    expected_diagnosis: string
  optimization_prompt:
    prompt: string
    current_metrics: object
    target_metrics: object
```

## Algorithm

1. **Task Classification**
   - Analyze task_type and context
   - Determine Gordon's required capabilities
   - Identify relevant Docker best practices

2. **Context Enrichment**
   - Extract Dockerfile content
   - Gather build logs and errors
   - Collect performance metrics
   - Identify optimization opportunities

3. **Prompt Construction**
   - Use structured prompt templates
   - Include specific constraints
   - Define success criteria
   - Add validation steps

4. **Validation Strategy**
   - Define expected Gordon outputs
   - Specify measurable improvements
   - Create verification commands

## Prompt Templates

### Build Optimization Prompt

```yaml
gordon_build_prompt:
  template: |
    I need help optimizing a Docker build for a {{RUNTIME}} application.

    **Current Dockerfile:**
    ```dockerfile
    {{DOCKERFILE_CONTENT}}
    ```

    **Current Metrics:**
    - Image Size: {{CURRENT_SIZE}}
    - Build Time: {{BUILD_TIME}}
    - Layer Count: {{LAYER_COUNT}}

    **Optimization Goals:**
    {{#each GOALS}}
    - {{this}}
    {{/each}}

    **Constraints:**
    - Must use {{BASE_IMAGE}} or compatible
    - Must maintain {{RUNTIME_VERSION}}
    - Must support {{PLATFORM}}

    **Please provide:**
    1. Optimized Dockerfile with multi-stage build
    2. Explanation of each optimization
    3. Expected size reduction
    4. Build command with cache optimization
    5. .dockerignore recommendations

  expected_actions:
    - "Analyze current Dockerfile structure"
    - "Suggest multi-stage build improvements"
    - "Recommend layer consolidation"
    - "Provide optimized Dockerfile"
    - "Estimate performance improvements"

  validation_criteria: |
    - Image size reduced by at least 30%
    - Build time improved or maintained
    - All functionality preserved
    - Security best practices applied
```

### Debug Prompt

```yaml
gordon_debug_prompt:
  template: |
    I'm experiencing a Docker build/runtime failure and need debugging assistance.

    **Error Context:**
    ```
    {{ERROR_LOGS}}
    ```

    **Dockerfile:**
    ```dockerfile
    {{DOCKERFILE_CONTENT}}
    ```

    **Build Command:**
    ```bash
    {{BUILD_COMMAND}}
    ```

    **Environment:**
    - Docker Version: {{DOCKER_VERSION}}
    - Platform: {{PLATFORM}}
    - Build Context Size: {{CONTEXT_SIZE}}

    **Previous Attempts:**
    {{#each BUILD_HISTORY}}
    - Attempt {{@index}}: {{this.error}}
    {{/each}}

    **Please diagnose:**
    1. Root cause of the failure
    2. Step-by-step resolution
    3. Prevention strategies
    4. Alternative approaches if needed

  context_provided:
    error_logs: "Full error output"
    dockerfile: "Complete Dockerfile"
    build_command: "Exact command used"
    environment: "System information"

  expected_diagnosis: |
    - Clear identification of root cause
    - Actionable resolution steps
    - Explanation of why error occurred
    - Preventive measures for future
```

### Security Hardening Prompt

```yaml
gordon_security_prompt:
  template: |
    I need to harden the security of my Docker image for production deployment.

    **Current Dockerfile:**
    ```dockerfile
    {{DOCKERFILE_CONTENT}}
    ```

    **Security Concerns:**
    {{#each CONCERNS}}
    - {{this}}
    {{/each}}

    **Compliance Requirements:**
    - Non-root user execution
    - Minimal attack surface
    - No secrets in image
    - Vulnerability scanning passed

    **Please provide:**
    1. Security-hardened Dockerfile
    2. Explanation of each security measure
    3. Vulnerability scan recommendations
    4. Runtime security configurations
    5. Secret management strategy

  expected_actions:
    - "Add non-root user"
    - "Minimize installed packages"
    - "Remove unnecessary tools"
    - "Configure health checks"
    - "Implement secret management"

  validation_criteria: |
    - Container runs as non-root
    - No HIGH/CRITICAL vulnerabilities
    - Minimal base image used
    - Health checks configured
    - No secrets in image layers
```

### Performance Optimization Prompt

```yaml
gordon_performance_prompt:
  template: |
    I need to optimize Docker image build performance and runtime efficiency.

    **Current Performance:**
    - Build Time: {{BUILD_TIME}}
    - Image Size: {{IMAGE_SIZE}}
    - Startup Time: {{STARTUP_TIME}}
    - Memory Usage: {{MEMORY_USAGE}}

    **Dockerfile:**
    ```dockerfile
    {{DOCKERFILE_CONTENT}}
    ```

    **Optimization Targets:**
    - Build Time: < {{TARGET_BUILD_TIME}}
    - Image Size: < {{TARGET_SIZE}}
    - Startup Time: < {{TARGET_STARTUP}}

    **Please optimize for:**
    1. Faster build times with layer caching
    2. Smaller image size
    3. Faster container startup
    4. Efficient resource usage

  expected_actions:
    - "Implement BuildKit features"
    - "Optimize layer caching"
    - "Reduce image size"
    - "Improve startup performance"

  validation_criteria: |
    - Build time reduced by 40%
    - Image size reduced by 50%
    - Startup time < 5 seconds
    - Memory footprint optimized
```

## Prompt Engineering Best Practices

```yaml
best_practices:
  structure:
    - "Start with clear objective"
    - "Provide complete context"
    - "Specify constraints explicitly"
    - "Define success criteria"
    - "Request actionable outputs"

  context_inclusion:
    - "Full Dockerfile content"
    - "Error logs (if debugging)"
    - "Current metrics"
    - "Environment details"
    - "Previous attempts"

  output_specification:
    - "Request numbered steps"
    - "Ask for explanations"
    - "Require validation commands"
    - "Specify format (code blocks)"

  validation:
    - "Define measurable criteria"
    - "Include verification commands"
    - "Specify expected improvements"
```

## Example Usage Scenarios

### Scenario 1: Build Failure Debug

```yaml
input:
  task_type: "debug"
  context:
    dockerfile_path: "./Dockerfile"
    image_name: "todo-backend"
    error_logs: |
      ERROR [builder 3/5] RUN npm ci --only=production
      npm ERR! code ENOENT
      npm ERR! syscall open
      npm ERR! path /app/package.json

output:
  gordon_debug_prompt:
    prompt: |
      Debug Docker build failure for Node.js application.
      Error: package.json not found in /app directory.

      Dockerfile shows COPY package*.json ./ before RUN npm ci.

      Diagnose why package.json is not accessible and provide fix.
```

### Scenario 2: Image Size Optimization

```yaml
input:
  task_type: "optimize"
  context:
    image_name: "todo-backend"
    performance_metrics:
      current_size: "850MB"
      layer_count: 28
  optimization_goals: ["size", "layers"]

output:
  optimization_prompt:
    prompt: |
      Optimize Docker image size from 850MB to < 200MB.
      Current: 28 layers, Node.js application.

      Provide multi-stage Dockerfile with:
      - Alpine base image
      - Layer consolidation
      - Production-only dependencies
      - .dockerignore optimization
```

### Scenario 3: Security Hardening

```yaml
input:
  task_type: "security"
  context:
    dockerfile_path: "./Dockerfile"
    image_name: "todo-backend"
  constraints:
    compliance: ["non-root", "minimal-packages", "no-secrets"]

output:
  gordon_security_prompt:
    prompt: |
      Harden Docker image security for production.

      Requirements:
      - Non-root user execution
      - Minimal attack surface
      - No secrets in layers
      - Pass vulnerability scan

      Provide hardened Dockerfile with explanations.
```

## Integration with Docker AI (Gordon)

```yaml
gordon_integration:
  invocation_method: "CLI"
  command_template: |
    docker ai "{{GENERATED_PROMPT}}"

  response_handling:
    - "Parse Gordon's suggestions"
    - "Extract code blocks"
    - "Validate recommendations"
    - "Apply changes incrementally"

  feedback_loop:
    - "Test Gordon's suggestions"
    - "Measure improvements"
    - "Refine prompt if needed"
    - "Document successful patterns"
```

## Error Handling

```yaml
error_scenarios:
  - error: "Gordon not available"
    detection: "docker ai: command not found"
    resolution: "Install Docker Desktop with AI features or use manual optimization"

  - error: "Prompt too vague"
    detection: "Gordon requests more context"
    resolution: "Enrich prompt with additional details"

  - error: "Suggested changes break build"
    detection: "Build fails after applying Gordon's suggestions"
    resolution: "Revert changes, refine prompt with error context"
```

## Performance Targets

- Prompt generation: < 1 second
- Gordon response time: 5-30 seconds (depends on Docker AI)
- Validation of suggestions: < 2 minutes

## Integration Points

- **Depends On**: `dockerfile-generator`, `docker-build-orchestrator`
- **Next Skill**: Kubernetes deployment skills
- **Outputs To**: Build optimization pipeline

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
