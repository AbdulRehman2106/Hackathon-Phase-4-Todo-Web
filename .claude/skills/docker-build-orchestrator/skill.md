# Docker Build Orchestrator Skill

## Skill ID
`docker-build-orchestrator`

## Category
🐳 Containerization

## Responsibility
Generate docker build commands, define image tagging strategy, establish local image validation process, and ensure compatibility with Minikube.

## Inputs

```yaml
inputs:
  dockerfile_path: string       # Path to Dockerfile
  image_name: string            # Base image name
  registry: string              # Container registry (default: local)
  environment: string           # "development" | "staging" | "production"
  build_context: string         # Build context path (default: ".")
  build_args: object            # Build-time arguments
  platform: string              # Target platform (default: "linux/amd64")
  cache_strategy: string        # "none" | "local" | "registry"
```

## Outputs

```yaml
outputs:
  build_commands:
    - command: string
      description: string
      order: integer
  tagging_strategy:
    tags: array                 # List of tags to apply
    naming_convention: string   # Tag naming pattern
    versioning_scheme: string   # Semantic versioning approach
  validation_checklist:
    - check: string
      command: string
      success_criteria: string
```

## Algorithm

1. **Environment Detection**
   - Detect if Minikube is running
   - Check Docker daemon availability
   - Verify build context exists

2. **Tagging Strategy Generation**
   - **Development**: `{image}:dev-{git-sha-short}`
   - **Staging**: `{image}:staging-{version}`
   - **Production**: `{image}:{version}`, `{image}:latest`
   - Add timestamp tag: `{image}:{version}-{timestamp}`

3. **Build Command Construction**
   - Base build command with optimizations
   - Multi-platform support if needed
   - Cache configuration
   - Build args injection

4. **Minikube Compatibility**
   - Use `minikube docker-env` for local builds
   - Skip registry push for local development
   - Configure image pull policy

5. **Validation Pipeline**
   - Image build success
   - Size validation
   - Security scan
   - Runtime test

## Build Commands Template

```yaml
build_commands:
  # Step 1: Set Minikube Docker environment (development only)
  - command: |
      eval $(minikube docker-env)
    description: "Configure Docker to use Minikube's Docker daemon"
    order: 1
    environment: ["development"]

  # Step 2: Build Docker image
  - command: |
      docker build \
        --file {{DOCKERFILE_PATH}} \
        --tag {{IMAGE_NAME}}:{{TAG}} \
        --build-arg NODE_ENV={{ENVIRONMENT}} \
        --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
        --build-arg VCS_REF=$(git rev-parse --short HEAD) \
        --platform {{PLATFORM}} \
        --progress=plain \
        {{BUILD_CONTEXT}}
    description: "Build Docker image with metadata"
    order: 2
    environment: ["development", "staging", "production"]

  # Step 3: Tag image with additional tags
  - command: |
      docker tag {{IMAGE_NAME}}:{{TAG}} {{IMAGE_NAME}}:latest
    description: "Tag image as latest"
    order: 3
    environment: ["production"]

  # Step 4: Verify image was created
  - command: |
      docker images {{IMAGE_NAME}}:{{TAG}}
    description: "Verify image exists"
    order: 4
    environment: ["development", "staging", "production"]
```

## Tagging Strategy

```yaml
tagging_strategy:
  development:
    pattern: "{image}:dev-{git-sha}"
    example: "todo-backend:dev-a3f2c1b"
    retention: "7 days"

  staging:
    pattern: "{image}:staging-{version}"
    example: "todo-backend:staging-1.2.0"
    retention: "30 days"

  production:
    patterns:
      - "{image}:{version}"
      - "{image}:latest"
      - "{image}:{version}-{timestamp}"
    examples:
      - "todo-backend:1.2.0"
      - "todo-backend:latest"
      - "todo-backend:1.2.0-20260216"
    retention: "90 days"

  naming_convention: "lowercase-with-hyphens"
  versioning_scheme: "semantic-versioning-2.0.0"
```

## Validation Checklist

```yaml
validation_checklist:
  - check: "Image build successful"
    command: "docker build -t {{IMAGE_NAME}}:{{TAG}} ."
    success_criteria: "Exit code 0, 'Successfully built' in output"

  - check: "Image size within limits"
    command: "docker images {{IMAGE_NAME}}:{{TAG}} --format '{{.Size}}'"
    success_criteria: "< 500MB"

  - check: "Image layers optimized"
    command: "docker history {{IMAGE_NAME}}:{{TAG}} --no-trunc"
    success_criteria: "< 20 layers"

  - check: "Security vulnerabilities scan"
    command: "docker scan {{IMAGE_NAME}}:{{TAG}} || trivy image {{IMAGE_NAME}}:{{TAG}}"
    success_criteria: "No HIGH or CRITICAL vulnerabilities"

  - check: "Container starts successfully"
    command: "docker run -d --name test-{{TAG}} {{IMAGE_NAME}}:{{TAG}}"
    success_criteria: "Container status: running"

  - check: "Health check passes"
    command: "docker inspect test-{{TAG}} | jq '.[0].State.Health.Status'"
    success_criteria: "healthy"

  - check: "Cleanup test container"
    command: "docker rm -f test-{{TAG}}"
    success_criteria: "Container removed"

  - check: "Minikube can pull image (dev only)"
    command: "minikube image ls | grep {{IMAGE_NAME}}"
    success_criteria: "Image listed in Minikube"
```

## Minikube Integration

```yaml
minikube_config:
  # Use Minikube's Docker daemon for local development
  docker_env_setup: |
    eval $(minikube docker-env)

  # Image pull policy for local images
  image_pull_policy: "Never"  # Don't pull from registry

  # Verify Minikube has access to image
  verification_command: |
    minikube image ls | grep {{IMAGE_NAME}}:{{TAG}}

  # Load image into Minikube (alternative method)
  load_command: |
    minikube image load {{IMAGE_NAME}}:{{TAG}}
```

## Build Optimization Strategies

```yaml
optimization:
  cache_strategy:
    local:
      description: "Use local Docker layer cache"
      command_flag: "--cache-from {{IMAGE_NAME}}:latest"

    registry:
      description: "Use registry cache"
      command_flag: "--cache-from {{REGISTRY}}/{{IMAGE_NAME}}:cache"

    buildkit:
      description: "Use BuildKit for advanced caching"
      environment: "DOCKER_BUILDKIT=1"
      command_flag: "--cache-from type=registry,ref={{REGISTRY}}/{{IMAGE_NAME}}:cache"

  multi_platform:
    enabled: false
    platforms: ["linux/amd64", "linux/arm64"]
    command: "docker buildx build --platform linux/amd64,linux/arm64"
```

## Error Handling

```yaml
error_scenarios:
  - error: "Docker daemon not running"
    detection: "Cannot connect to the Docker daemon"
    resolution: "Start Docker Desktop or run 'systemctl start docker'"

  - error: "Minikube not running"
    detection: "minikube: command not found or not running"
    resolution: "Start Minikube with 'minikube start'"

  - error: "Build context too large"
    detection: "Sending build context to Docker daemon"
    resolution: "Add files to .dockerignore"

  - error: "Out of disk space"
    detection: "no space left on device"
    resolution: "Run 'docker system prune -a' to free space"

  - error: "Base image pull failed"
    detection: "Error response from daemon: pull access denied"
    resolution: "Check internet connection and base image name"
```

## Example Usage

```bash
# Input specification
{
  "dockerfile_path": "./Dockerfile",
  "image_name": "todo-backend",
  "environment": "development",
  "build_context": ".",
  "platform": "linux/amd64"
}

# Generated output
{
  "build_commands": [
    {
      "command": "eval $(minikube docker-env)",
      "description": "Configure Docker for Minikube",
      "order": 1
    },
    {
      "command": "docker build -t todo-backend:dev-a3f2c1b .",
      "description": "Build Docker image",
      "order": 2
    }
  ],
  "tagging_strategy": {
    "tags": ["todo-backend:dev-a3f2c1b"],
    "naming_convention": "lowercase-with-hyphens"
  }
}
```

## Integration Points

- **Depends On**: `dockerfile-generator` (requires Dockerfile)
- **Next Skill**: `gordon-prompt-generator` (for AI-assisted debugging)
- **Outputs To**: `kubernetes-deployment-designer` (image reference)

## Performance Targets

- Build command generation: < 1 second
- Image build time: < 3 minutes (standard project)
- Validation pipeline: < 2 minutes

## CI/CD Integration

```yaml
github_actions_example: |
  - name: Build Docker Image
    run: |
      docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} .
      docker tag ${{ env.IMAGE_NAME }}:${{ github.sha }} ${{ env.IMAGE_NAME }}:latest

gitlab_ci_example: |
  build:
    script:
      - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
      - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
```

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
