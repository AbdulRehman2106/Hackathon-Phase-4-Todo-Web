# Implementation Plan: Kubernetes Deployment with AI DevOps

**Branch**: `003-k8s-deployment` | **Date**: 2026-02-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-k8s-deployment/spec.md`

## Summary

Deploy the Phase III Todo Chatbot application to a local Kubernetes cluster (Minikube) with full containerization, Helm-managed deployment, and AI-assisted DevOps operations. The deployment will use Docker Desktop with Gordon for container optimization, kubectl-ai for intelligent Kubernetes operations, and kagent for cluster health analysis. All services will be stateless with data persisted to Neon PostgreSQL, and the AI chatbot will remain fully operational through Cohere API integration.

## Technical Context

**Language/Version**:
- Frontend: TypeScript 5.x with Next.js 16+ (App Router)
- Backend: Python 3.11 with FastAPI
- Infrastructure: YAML for Kubernetes manifests, Helm charts

**Primary Dependencies**:
- Docker Desktop (with Gordon AI)
- Minikube (local Kubernetes cluster)
- Helm 3.x (package manager)
- kubectl-ai (AI-assisted Kubernetes CLI)
- kagent (cluster diagnostics)
- Cohere API (AI backend)
- Neon PostgreSQL (database)

**Storage**:
- Application data: Neon PostgreSQL (external, persistent)
- Container images: Local Docker registry or Docker Desktop
- Kubernetes state: Minikube cluster storage
- Secrets: Kubernetes Secrets (encrypted at rest)

**Testing**:
- Container validation: Docker build + run tests
- Kubernetes validation: Helm lint, kubectl dry-run
- Integration testing: End-to-end deployment tests
- AI operations: kubectl-ai and kagent diagnostic tests

**Target Platform**:
- Local development: Minikube on Docker Desktop (Windows/macOS/Linux)
- Container runtime: Docker
- Orchestration: Kubernetes 1.28+

**Project Type**: Web application (containerized microservices)

**Performance Goals**:
- Deployment time: < 5 minutes (Helm install to running pods)
- Pod startup: < 2 minutes (all replicas Running)
- Image build: < 3 minutes per service
- Health check response: < 5 seconds
- Application response: < 2.5 seconds per AI request

**Constraints**:
- Frontend image: < 200MB
- Backend image: < 150MB
- Memory per pod: < 1GB
- CPU per pod: < 1 core
- No manual kubectl apply (use kubectl-ai or Helm)
- No hardcoded secrets
- Stateless containers only

**Scale/Scope**:
- Services: 2 (frontend, backend)
- Replicas: 2-5 per service (configurable)
- Concurrent users: 100+
- Deployment environments: 1 (local Minikube)
- Helm charts: 2 (frontend, backend)
- Dockerfiles: 2 (multi-stage)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Spec-Driven Development ✅
- **Status**: PASS
- **Evidence**: Complete specification exists at specs/003-k8s-deployment/spec.md with 20 functional requirements, 15 success criteria, and 5 prioritized user stories
- **Compliance**: All infrastructure will be defined in Helm charts and Dockerfiles before deployment

### Principle II: Agentic Workflow ✅
- **Status**: PASS
- **Evidence**: Plan mandates use of kubectl-ai (not raw kubectl), kagent for diagnostics, Gordon for Docker operations
- **Compliance**: All deployment operations will use AI-assisted tools, no manual kubectl apply

### Principle III: Separation of Concerns ✅
- **Status**: PASS
- **Evidence**: Frontend and backend in separate containers, AI logic inside backend, database external
- **Compliance**: Each service has independent Helm chart, ClusterIP services for internal communication

### Principle IV: Security by Design ✅
- **Status**: PASS
- **Evidence**: Kubernetes Secrets for all sensitive data, no hardcoded credentials, JWT verification maintained
- **Compliance**: Cohere API key in Secret, containers run as non-root, RBAC configured

### Principle V: UI/UX Excellence ✅
- **Status**: PASS (inherited from Phase III)
- **Evidence**: UI already polished in Phase III, deployment maintains existing quality
- **Compliance**: No UI changes in Phase IV, existing standards preserved

### Principle VI: Stateless AI Architecture ✅
- **Status**: PASS
- **Evidence**: All conversation state persisted to PostgreSQL, no in-memory state
- **Compliance**: Containers are stateless, database external, horizontal scaling supported

### Principle VII: Cloud-Native First ✅
- **Status**: PASS
- **Evidence**: Full containerization, Kubernetes orchestration, health probes, resource limits
- **Compliance**: Multi-stage Dockerfiles, liveness/readiness probes, HPA-ready, graceful shutdown

### Principle VIII: AI-Augmented DevOps ✅
- **Status**: PASS
- **Evidence**: kubectl-ai for operations, kagent for diagnostics, Gordon for Docker optimization
- **Compliance**: No manual operations, AI tools mandatory, diagnostic workflow defined

**Overall Gate Status**: ✅ PASS - All principles satisfied, proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/003-k8s-deployment/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file (implementation plan)
├── research.md          # Phase 0: Technology research and decisions
├── data-model.md        # Phase 1: Container and K8s resource models
├── quickstart.md        # Phase 1: Deployment quick start guide
├── contracts/           # Phase 1: Helm values contracts, API schemas
│   ├── frontend-values.yaml
│   ├── backend-values.yaml
│   └── secrets-template.yaml
├── checklists/          # Quality validation
│   └── requirements.md
└── tasks.md             # Phase 2: Implementation tasks (created by /sp.tasks)
```

### Source Code (repository root)

```text
# Existing application structure (Phase III)
frontend/
├── src/
│   ├── app/             # Next.js App Router
│   ├── components/      # React components
│   └── lib/             # Utilities, API client
├── public/
├── package.json
└── Dockerfile           # NEW: Multi-stage build

backend/
├── src/
│   ├── models/          # SQLModel models
│   ├── routers/         # FastAPI routes
│   ├── services/        # Business logic
│   └── ai/              # Cohere integration, MCP tools
├── tests/
├── requirements.txt
└── Dockerfile           # NEW: Multi-stage build

# NEW: Kubernetes deployment infrastructure
helm/
├── frontend/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── configmap.yaml
│       ├── secret.yaml
│       └── hpa.yaml
└── backend/
    ├── Chart.yaml
    ├── values.yaml
    ├── values-dev.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── configmap.yaml
        ├── secret.yaml
        └── hpa.yaml

# NEW: Deployment scripts and utilities
scripts/
├── deploy.sh            # Deployment automation
├── validate.sh          # Pre-deployment validation
└── diagnostics.sh       # kubectl-ai and kagent wrappers

# Configuration
.env.example             # Template for local development
k8s-secrets.yaml.example # Template for Kubernetes secrets
```

**Structure Decision**: Web application structure (Option 2) with added Kubernetes infrastructure. Existing frontend/ and backend/ directories remain unchanged. New helm/ directory contains deployment charts. New scripts/ directory contains AI-assisted deployment automation.

## Complexity Tracking

> No violations detected. All constitution principles are satisfied.

## Phase 0: Research & Technology Decisions

### Research Areas

1. **Docker Multi-Stage Build Optimization**
   - **Decision**: Use Alpine-based images for minimal size
   - **Rationale**: Alpine Linux provides smallest base images (5MB vs 100MB+), reducing attack surface and deployment time
   - **Alternatives Considered**:
     - Distroless images (rejected: more complex, harder to debug)
     - Standard Debian images (rejected: too large, >200MB base)
   - **Implementation**:
     - Frontend: `node:20-alpine` base
     - Backend: `python:3.11-slim` base (slim preferred over alpine for Python due to wheel compatibility)

2. **Helm Chart Structure**
   - **Decision**: Separate charts for frontend and backend
   - **Rationale**: Independent versioning, scaling, and deployment of each service
   - **Alternatives Considered**:
     - Monolithic chart (rejected: tight coupling, harder to scale independently)
     - Umbrella chart (rejected: overkill for 2 services)
   - **Implementation**: Two independent charts in helm/frontend and helm/backend

3. **Kubernetes Secrets Management**
   - **Decision**: Kubernetes native Secrets with base64 encoding
   - **Rationale**: Built-in, no external dependencies, sufficient for local development
   - **Alternatives Considered**:
     - Sealed Secrets (rejected: adds complexity for local dev)
     - External Secrets Operator (rejected: requires external secret store)
     - HashiCorp Vault (rejected: overkill for local deployment)
   - **Implementation**: kubectl create secret, mounted as environment variables

4. **Service Mesh**
   - **Decision**: No service mesh for Phase IV
   - **Rationale**: Unnecessary complexity for 2 services on local cluster
   - **Alternatives Considered**:
     - Istio (rejected: heavy resource usage, complex for local dev)
     - Linkerd (rejected: still adds overhead for minimal benefit)
   - **Implementation**: Direct ClusterIP services, no mesh

5. **Ingress Controller**
   - **Decision**: Minikube ingress addon (NGINX)
   - **Rationale**: Built-in, simple configuration, sufficient for local access
   - **Alternatives Considered**:
     - Traefik (rejected: requires separate installation)
     - Kong (rejected: overkill for local dev)
   - **Implementation**: `minikube addons enable ingress`, simple Ingress resource

6. **Container Registry**
   - **Decision**: Local Docker Desktop registry
   - **Rationale**: No external dependencies, images available immediately after build
   - **Alternatives Considered**:
     - Minikube registry addon (rejected: requires image push step)
     - Docker Hub (rejected: requires authentication, slower)
   - **Implementation**: Build images locally, Minikube uses Docker Desktop images directly

7. **Health Check Strategy**
   - **Decision**: HTTP probes on /health (liveness) and /ready (readiness)
   - **Rationale**: Standard pattern, easy to implement, clear semantics
   - **Alternatives Considered**:
     - TCP probes (rejected: less informative)
     - Exec probes (rejected: requires shell in container)
   - **Implementation**:
     - Liveness: GET /health (checks app is alive)
     - Readiness: GET /ready (checks dependencies available)

8. **Resource Limits Strategy**
   - **Decision**: Set both requests and limits for predictable QoS
   - **Rationale**: Guaranteed QoS class ensures pods get resources they need
   - **Alternatives Considered**:
     - Requests only (rejected: unpredictable performance)
     - Limits only (rejected: no resource guarantee)
   - **Implementation**:
     - Frontend: 100m CPU request, 500m limit; 256Mi memory request, 512Mi limit
     - Backend: 250m CPU request, 1000m limit; 512Mi memory request, 1Gi limit

9. **HPA Configuration**
   - **Decision**: CPU-based autoscaling with 80% target
   - **Rationale**: Simple, effective for most workloads, no custom metrics needed
   - **Alternatives Considered**:
     - Memory-based (rejected: less predictable for web apps)
     - Custom metrics (rejected: requires metrics server setup)
   - **Implementation**: HPA targeting 80% CPU, min 2 replicas, max 5 replicas

10. **Logging Strategy**
    - **Decision**: Structured JSON logs to stdout
    - **Rationale**: Kubernetes captures stdout automatically, JSON enables parsing
    - **Alternatives Considered**:
      - File-based logging (rejected: requires volume mounts)
      - Sidecar logging (rejected: adds complexity)
    - **Implementation**: Winston (Node.js) and structlog (Python) for JSON output

### Technology Stack Summary

| Component | Technology | Version | Rationale |
|-----------|-----------|---------|-----------|
| Container Runtime | Docker Desktop | Latest | Built-in Gordon AI, local development |
| Orchestration | Minikube | 1.32+ | Local Kubernetes, easy setup |
| Package Manager | Helm | 3.x | Standard K8s packaging, templating |
| AI Operations | kubectl-ai | Latest | Intelligent K8s operations |
| Diagnostics | kagent | Latest | Cluster health analysis |
| Docker AI | Gordon | Built-in | Dockerfile optimization |
| Frontend Base | node:20-alpine | 20-alpine | Minimal size, security |
| Backend Base | python:3.11-slim | 3.11-slim | Python wheel compatibility |
| Ingress | NGINX (Minikube addon) | Latest | Simple, built-in |
| Secrets | Kubernetes Secrets | Native | No external dependencies |

## Phase 1: Design & Contracts

### Data Model (Container & Kubernetes Resources)

See [data-model.md](./data-model.md) for complete resource specifications.

**Key Resources**:
- **Container Images**: Frontend and backend Docker images with multi-stage builds
- **Deployments**: Kubernetes Deployment resources managing pod replicas
- **Services**: ClusterIP services for internal communication
- **Secrets**: Kubernetes Secrets for API keys and credentials
- **ConfigMaps**: Application configuration (non-sensitive)
- **HPA**: Horizontal Pod Autoscalers for automatic scaling
- **Ingress**: External access routing (optional)

### API Contracts

See [contracts/](./contracts/) directory for complete Helm values schemas and API specifications.

**Helm Values Contracts**:
- `frontend-values.yaml`: Frontend chart configuration schema
- `backend-values.yaml`: Backend chart configuration schema
- `secrets-template.yaml`: Required secrets structure

### Quick Start Guide

See [quickstart.md](./quickstart.md) for step-by-step deployment instructions.

**Quick Start Summary**:
1. Prerequisites: Install Docker Desktop, Minikube, Helm, kubectl-ai, kagent
2. Start Minikube: `minikube start --cpus=4 --memory=8192`
3. Build images: `docker build -t todo-frontend:latest ./frontend`
4. Deploy with Helm: `helm install todo-frontend ./helm/frontend`
5. Verify: `kubectl-ai "check pod status for todo-frontend"`
6. Access: `minikube service todo-frontend`

## Implementation Phases

### Phase 0: Environment Setup ✅ (Complete)
- Research completed above
- Technology decisions documented
- No blockers identified

### Phase 1: Design & Contracts ✅ (Complete)
- Data model defined (see data-model.md)
- Helm values contracts specified (see contracts/)
- Quick start guide created (see quickstart.md)

### Phase 2: Implementation Tasks
- **Next Step**: Run `/sp.tasks` to generate detailed implementation tasks
- **Expected Output**: tasks.md with dependency-ordered task breakdown
- **Task Categories**:
  - Environment preparation
  - Dockerfile creation
  - Helm chart development
  - Deployment automation
  - Testing and validation
  - Documentation

## Dependencies

### External Dependencies
- Docker Desktop (with Gordon enabled)
- Minikube (4 CPU, 8GB RAM minimum)
- Helm 3.x
- kubectl-ai (via kubectl krew)
- kagent
- Neon PostgreSQL (accessible from Minikube)
- Cohere API key

### Internal Dependencies
- Phase III application code (frontend and backend)
- Better Auth JWT authentication
- MCP tools implementation
- Database schema and migrations

### Dependency Graph
```
Environment Setup
    ↓
Dockerfile Creation (Frontend & Backend in parallel)
    ↓
Local Image Build & Test
    ↓
Helm Chart Creation (Frontend & Backend in parallel)
    ↓
Secrets Configuration
    ↓
Minikube Deployment
    ↓
Service Validation
    ↓
AI Operations Testing (kubectl-ai, kagent)
    ↓
Documentation & Reproducibility Testing
```

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Minikube resource exhaustion | High | Medium | Set resource limits, monitor with kagent |
| Docker image size exceeds limits | Medium | Low | Multi-stage builds, Alpine base, Gordon optimization |
| Secrets misconfiguration | High | Medium | Template files, validation scripts, clear documentation |
| Database connectivity from Minikube | High | Medium | Network configuration guide, connection testing |
| kubectl-ai/kagent not available | Medium | Low | Fallback to standard kubectl with documentation |
| Helm chart errors | Medium | Medium | Helm lint, dry-run validation before install |
| Pod CrashLoopBackOff | High | Medium | Comprehensive health checks, kubectl-ai diagnostics |

## Success Criteria Validation

All success criteria from spec.md will be validated:
- ✅ SC-001: Deployment time < 5 minutes (measured with `time helm install`)
- ✅ SC-002: Pods Running < 2 minutes (measured with `kubectl get pods --watch`)
- ✅ SC-003: Frontend image < 200MB (measured with `docker images`)
- ✅ SC-004: Backend image < 150MB (measured with `docker images`)
- ✅ SC-005: Health checks < 5 seconds (measured with `curl /health`)
- ✅ SC-006: Pod restart recovery (tested with `kubectl delete pod`)
- ✅ SC-007: Scaling 2→5 replicas < 1 minute (measured with `kubectl scale`)
- ✅ SC-008: Structured JSON logs (validated with `kubectl logs | jq`)
- ✅ SC-009: kubectl-ai diagnostics (tested with CrashLoopBackOff scenario)
- ✅ SC-010: kagent analysis < 30 seconds (measured with `time kagent analyze`)
- ✅ SC-011: New developer deployment < 30 minutes (timed walkthrough)
- ✅ SC-012: 99.9% uptime during rolling update (monitored during `helm upgrade`)
- ✅ SC-013: Zero secrets in images (scanned with `docker history`)
- ✅ SC-014: Non-root containers (verified with `docker inspect`)
- ✅ SC-015: 100 concurrent users (load tested with `hey` or `ab`)

## Next Steps

1. **Generate Implementation Tasks**: Run `/sp.tasks` to create detailed task breakdown
2. **Review and Approve Plan**: Ensure all stakeholders agree with approach
3. **Begin Implementation**: Follow task order in tasks.md
4. **Continuous Validation**: Check constitution compliance at each phase
5. **Documentation**: Update quickstart.md as implementation progresses

---

**Plan Status**: Complete and ready for task generation
**Constitution Compliance**: ✅ All principles satisfied
**Blockers**: None identified
**Ready for**: `/sp.tasks` command
