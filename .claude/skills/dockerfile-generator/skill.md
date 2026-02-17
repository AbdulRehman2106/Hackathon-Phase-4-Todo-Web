# Dockerfile Generator Skill

## Skill ID
`dockerfile-generator`

## Category
🐳 Containerization

## Responsibility
Generate optimized multi-stage Dockerfiles with auto-detection of Node.js or Python backends, image size reduction, build args, environment variables, and production-ready configuration.

## Inputs

```yaml
inputs:
  project_path: string          # Path to project root
  runtime: string               # "node" | "python" | "auto-detect"
  runtime_version: string       # e.g., "20-alpine", "3.11-slim"
  app_port: integer             # Application port (default: 3000 for Node, 8000 for Python)
  build_args: object            # Optional build-time arguments
  env_vars: object              # Runtime environment variables
  optimization_level: string    # "minimal" | "standard" | "aggressive"
```

## Outputs

```yaml
outputs:
  dockerfile:
    path: string                # Generated Dockerfile path
    content: string             # Full Dockerfile content
    stages: array               # List of build stages
  build_strategy:
    base_image: string          # Selected base image
    multi_stage: boolean        # Whether multi-stage build is used
    layer_count: integer        # Estimated layer count
    estimated_size: string      # Estimated final image size
  validation_steps:
    - step: string
      command: string
      expected_result: string
```

## Algorithm

1. **Runtime Detection**
   - If `runtime: "auto-detect"`:
     - Check for `package.json` → Node.js
     - Check for `requirements.txt` or `pyproject.toml` → Python
     - Check for `go.mod` → Go (future support)
   - Validate runtime version compatibility

2. **Base Image Selection**
   - Node.js: `node:{version}-alpine` for minimal size
   - Python: `python:{version}-slim` for balance
   - Apply security scanning to base image

3. **Multi-Stage Build Design**
   - **Stage 1 (Builder)**: Install dependencies, compile assets
   - **Stage 2 (Runtime)**: Copy only production artifacts
   - Minimize final image layers

4. **Optimization Application**
   - **Minimal**: Basic multi-stage, no caching
   - **Standard**: Layer caching, .dockerignore generation
   - **Aggressive**: Distroless images, security hardening

5. **Security Hardening**
   - Non-root user creation
   - Minimal package installation
   - Health check definition

## Dockerfile Template (Node.js)

```dockerfile
# Stage 1: Builder
FROM node:{{VERSION}}-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY . .

# Build application (if needed)
RUN npm run build || true

# Stage 2: Runtime
FROM node:{{VERSION}}-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy production dependencies and built assets
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Switch to non-root user
USER nodejs

# Expose application port
EXPOSE {{PORT}}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:{{PORT}}/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# Start application
CMD ["node", "dist/index.js"]
```

## Dockerfile Template (Python)

```dockerfile
# Stage 1: Builder
FROM python:{{VERSION}}-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY requirements.txt .

# Install Python dependencies
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:{{VERSION}}-slim

# Create non-root user
RUN useradd -m -u 1001 appuser

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Update PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Expose application port
EXPOSE {{PORT}}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:{{PORT}}/health')"

# Start application
CMD ["python", "main.py"]
```

## .dockerignore Template

```
# Dependencies
node_modules/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/

# Development
.git/
.gitignore
.env
.env.local
*.log
npm-debug.log*

# IDE
.vscode/
.idea/
*.swp
*.swo

# Testing
coverage/
.pytest_cache/
*.test.js

# Documentation
README.md
docs/

# CI/CD
.github/
.gitlab-ci.yml
```

## Validation Steps

```yaml
validation_steps:
  - step: "Build Docker image"
    command: "docker build -t {{IMAGE_NAME}}:test ."
    expected_result: "Successfully built"

  - step: "Check image size"
    command: "docker images {{IMAGE_NAME}}:test --format '{{.Size}}'"
    expected_result: "< 200MB for Node, < 150MB for Python"

  - step: "Scan for vulnerabilities"
    command: "docker scan {{IMAGE_NAME}}:test"
    expected_result: "No critical vulnerabilities"

  - step: "Test container startup"
    command: "docker run -d -p {{PORT}}:{{PORT}} {{IMAGE_NAME}}:test"
    expected_result: "Container running"

  - step: "Health check validation"
    command: "docker inspect {{IMAGE_NAME}}:test | jq '.[0].Config.Healthcheck'"
    expected_result: "Health check defined"
```

## Security Checklist

- [ ] Non-root user configured
- [ ] Minimal base image used
- [ ] No secrets in Dockerfile
- [ ] .dockerignore present
- [ ] Health check defined
- [ ] Vulnerability scan passed
- [ ] Image size optimized

## Example Usage

```bash
# Input specification
{
  "project_path": "./backend",
  "runtime": "node",
  "runtime_version": "20-alpine",
  "app_port": 3000,
  "optimization_level": "standard"
}

# Generated output
{
  "dockerfile": {
    "path": "./backend/Dockerfile",
    "stages": ["builder", "runtime"]
  },
  "build_strategy": {
    "base_image": "node:20-alpine",
    "multi_stage": true,
    "estimated_size": "150MB"
  }
}
```

## Integration Points

- **Next Skill**: `docker-build-orchestrator` (builds the generated Dockerfile)
- **Depends On**: Project structure analysis
- **Outputs To**: `gordon-prompt-generator` (for AI-assisted optimization)

## Error Handling

```yaml
error_scenarios:
  - error: "Runtime not detected"
    resolution: "Prompt user to specify runtime explicitly"

  - error: "Unsupported runtime version"
    resolution: "Suggest compatible versions"

  - error: "Missing dependency files"
    resolution: "Generate minimal dependency file template"
```

## Performance Targets

- Generation time: < 2 seconds
- Dockerfile validation: < 5 seconds
- Image build time: < 3 minutes (standard project)

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
