# Tasks: Kubernetes Deployment with AI DevOps

**Input**: Design documents from `/specs/003-k8s-deployment/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Tests are NOT explicitly requested in the specification, so test tasks are omitted per template guidelines.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This is a web application with:
- `frontend/` - Next.js application
- `backend/` - FastAPI application
- `helm/` - Helm charts for Kubernetes deployment
- `scripts/` - Deployment automation scripts

---

## Phase 1: Setup (Environment Preparation)

**Purpose**: Verify and install all required tools for Kubernetes deployment

- [ ] T001 Verify Docker Desktop installation (version >= 4.25) and ensure it's running
- [ ] T002 Verify Gordon (Docker AI) is available via Docker Desktop
- [ ] T003 Install Minikube and verify installation with `minikube version`
- [ ] T004 Install Helm 3.x and verify with `helm version`
- [ ] T005 Install kubectl-ai via krew: `kubectl krew install ai`
- [ ] T006 Install kagent CLI tool for cluster diagnostics
- [ ] T007 Start Minikube cluster with 4 CPU and 8GB RAM: `minikube start --cpus=4 --memory=8192`
- [ ] T008 Verify kubectl context points to Minikube: `kubectl config current-context`
- [ ] T009 Enable Minikube metrics-server addon: `minikube addons enable metrics-server`
- [ ] T010 Enable Minikube ingress addon: `minikube addons enable ingress`
- [ ] T011 Create .env.example file at repository root with required environment variables
- [ ] T012 Create k8s-secrets.yaml.example at repository root as template for Kubernetes secrets

**Checkpoint**: Environment ready - all tools installed and Minikube cluster running

---

## Phase 2: Foundational (Container Packaging - US2)

**Purpose**: Create optimized Docker containers for frontend and backend (US2 prerequisite for US1)

**⚠️ CRITICAL**: Kubernetes deployment (US1) cannot proceed until containers are built

### User Story 2: Container Packaging (Priority: P2)

**Goal**: Package frontend and backend as optimized Docker containers under size limits

**Independent Test**: Build images locally, run with `docker run`, verify application responds to health checks

- [ ] T013 [P] [US2] Create multi-stage Dockerfile for frontend in frontend/Dockerfile using node:20-alpine base
- [ ] T014 [P] [US2] Create multi-stage Dockerfile for backend in backend/Dockerfile using python:3.11-slim base
- [ ] T015 [P] [US2] Add .dockerignore to frontend/ excluding node_modules, .next, .git
- [ ] T016 [P] [US2] Add .dockerignore to backend/ excluding __pycache__, .pytest_cache, .git
- [ ] T017 [P] [US2] Add health check endpoint GET /health to frontend in frontend/src/app/health/route.ts
- [ ] T018 [P] [US2] Add readiness check endpoint GET /ready to frontend in frontend/src/app/ready/route.ts
- [ ] T019 [P] [US2] Add health check endpoint GET /health to backend in backend/src/routers/health.py
- [ ] T020 [P] [US2] Add readiness check endpoint GET /ready to backend in backend/src/routers/health.py
- [ ] T021 [US2] Build frontend Docker image: `docker build -t todo-frontend:v1.0.0 ./frontend`
- [ ] T022 [US2] Build backend Docker image: `docker build -t todo-backend:v1.0.0 ./backend`
- [ ] T023 [US2] Verify frontend image size is under 200MB: `docker images todo-frontend:v1.0.0`
- [ ] T024 [US2] Verify backend image size is under 150MB: `docker images todo-backend:v1.0.0`
- [ ] T025 [US2] Verify no secrets in frontend image: `docker history todo-frontend:v1.0.0 --no-trunc`
- [ ] T026 [US2] Verify no secrets in backend image: `docker history todo-backend:v1.0.0 --no-trunc`
- [ ] T027 [US2] Verify frontend runs as non-root: `docker inspect todo-frontend:v1.0.0 | grep User`
- [ ] T028 [US2] Verify backend runs as non-root: `docker inspect todo-backend:v1.0.0 | grep User`
- [ ] T029 [US2] Test frontend container locally: `docker run -p 3000:3000 todo-frontend:v1.0.0`
- [ ] T030 [US2] Test backend container locally with environment variables: `docker run -p 8000:8000 -e DATABASE_URL=... todo-backend:v1.0.0`
- [ ] T031 [US2] Tag images as latest: `docker tag todo-frontend:v1.0.0 todo-frontend:latest`
- [ ] T032 [US2] Tag backend as latest: `docker tag todo-backend:v1.0.0 todo-backend:latest`

**Checkpoint**: Docker images built, tested locally, and ready for Kubernetes deployment

---

## Phase 3: User Story 1 - Local Kubernetes Deployment (Priority: P1) 🎯 MVP

**Goal**: Deploy Todo Chatbot to Minikube with Helm charts, achieving production-like environment

**Independent Test**: Deploy to Minikube, access frontend in browser, verify all CRUD operations work end-to-end

### Helm Chart Creation

- [ ] T033 [P] [US1] Create frontend Helm chart structure: `helm create helm/frontend`
- [ ] T034 [P] [US1] Create backend Helm chart structure: `helm create helm/backend`
- [ ] T035 [P] [US1] Create frontend Chart.yaml in helm/frontend/Chart.yaml with name, version, description
- [ ] T036 [P] [US1] Create backend Chart.yaml in helm/backend/Chart.yaml with name, version, description
- [ ] T037 [P] [US1] Create frontend values.yaml in helm/frontend/values.yaml per contracts/frontend-values.yaml schema
- [ ] T038 [P] [US1] Create backend values.yaml in helm/backend/values.yaml per contracts/backend-values.yaml schema
- [ ] T039 [P] [US1] Create frontend Deployment template in helm/frontend/templates/deployment.yaml
- [ ] T040 [P] [US1] Create backend Deployment template in helm/backend/templates/deployment.yaml
- [ ] T041 [P] [US1] Create frontend Service template in helm/frontend/templates/service.yaml (ClusterIP, port 3000)
- [ ] T042 [P] [US1] Create backend Service template in helm/backend/templates/service.yaml (ClusterIP, port 8000)
- [ ] T043 [P] [US1] Create frontend ConfigMap template in helm/frontend/templates/configmap.yaml
- [ ] T044 [P] [US1] Create backend ConfigMap template in helm/backend/templates/configmap.yaml
- [ ] T045 [P] [US1] Create frontend HPA template in helm/frontend/templates/hpa.yaml (2-5 replicas, 80% CPU)
- [ ] T046 [P] [US1] Create backend HPA template in helm/backend/templates/hpa.yaml (2-5 replicas, 80% CPU)
- [ ] T047 [US1] Configure frontend Deployment with liveness probe (GET /health, 10s initial delay)
- [ ] T048 [US1] Configure frontend Deployment with readiness probe (GET /ready, 5s initial delay)
- [ ] T049 [US1] Configure backend Deployment with liveness probe (GET /health, 15s initial delay)
- [ ] T050 [US1] Configure backend Deployment with readiness probe (GET /ready, 10s initial delay)
- [ ] T051 [US1] Configure frontend resource limits: 100m-500m CPU, 256Mi-512Mi memory
- [ ] T052 [US1] Configure backend resource limits: 250m-1000m CPU, 512Mi-1Gi memory
- [ ] T053 [US1] Configure frontend security context: runAsNonRoot=true, runAsUser=1000
- [ ] T054 [US1] Configure backend security context: runAsNonRoot=true, runAsUser=1000
- [ ] T055 [US1] Configure frontend rolling update strategy: maxSurge=1, maxUnavailable=0
- [ ] T056 [US1] Configure backend rolling update strategy: maxSurge=1, maxUnavailable=0

### Secrets and Configuration

- [ ] T057 [US1] Create Kubernetes Secret for backend with DATABASE_URL, COHERE_API_KEY, JWT_SECRET
- [ ] T058 [US1] Verify secret created successfully: `kubectl get secret backend-secrets`
- [ ] T059 [US1] Verify secret has correct keys: `kubectl describe secret backend-secrets`

### Deployment

- [ ] T060 [US1] Validate frontend Helm chart: `helm lint helm/frontend`
- [ ] T061 [US1] Validate backend Helm chart: `helm lint helm/backend`
- [ ] T062 [US1] Dry-run frontend deployment: `helm install todo-frontend helm/frontend --dry-run --debug`
- [ ] T063 [US1] Dry-run backend deployment: `helm install todo-backend helm/backend --dry-run --debug`
- [ ] T064 [US1] Deploy backend to Minikube: `helm install todo-backend helm/backend --set image.tag=v1.0.0`
- [ ] T065 [US1] Wait for backend pods to be ready: `kubectl wait --for=condition=available deployment/todo-backend --timeout=120s`
- [ ] T066 [US1] Deploy frontend to Minikube: `helm install todo-frontend helm/frontend --set image.tag=v1.0.0`
- [ ] T067 [US1] Wait for frontend pods to be ready: `kubectl wait --for=condition=available deployment/todo-frontend --timeout=120s`
- [ ] T068 [US1] Verify all pods are Running: `kubectl get pods`
- [ ] T069 [US1] Verify all services are created: `kubectl get services`
- [ ] T070 [US1] Verify HPA is created: `kubectl get hpa`
- [ ] T071 [US1] Check frontend pod logs: `kubectl logs -l app=todo-frontend --tail=50`
- [ ] T072 [US1] Check backend pod logs: `kubectl logs -l app=todo-backend --tail=50`

### Validation and Testing

- [ ] T073 [US1] Port-forward frontend service: `kubectl port-forward service/todo-frontend 3000:3000`
- [ ] T074 [US1] Access frontend in browser at http://localhost:3000 and verify UI loads
- [ ] T075 [US1] Test user signup flow through UI
- [ ] T076 [US1] Test user login flow through UI
- [ ] T077 [US1] Test create todo via UI and verify it persists
- [ ] T078 [US1] Test list todos via UI
- [ ] T079 [US1] Test update todo via UI
- [ ] T080 [US1] Test delete todo via UI
- [ ] T081 [US1] Test AI chatbot: "Add a task to buy groceries"
- [ ] T082 [US1] Verify todo created by AI appears in list
- [ ] T083 [US1] Test pod restart recovery: `kubectl delete pod -l app=todo-backend` and verify auto-recovery
- [ ] T084 [US1] Verify data persists after pod restart
- [ ] T085 [US1] Test scaling: `kubectl scale deployment/todo-backend --replicas=5`
- [ ] T086 [US1] Verify 5 backend pods are running within 1 minute
- [ ] T087 [US1] Scale back to 2 replicas: `kubectl scale deployment/todo-backend --replicas=2`
- [ ] T088 [US1] Test rolling update: `helm upgrade todo-backend helm/backend --set image.tag=v1.0.1`
- [ ] T089 [US1] Verify zero downtime during rolling update (monitor with `kubectl get pods --watch`)
- [ ] T090 [US1] Measure deployment time from `helm install` to all pods Running (target: < 5 minutes)

**Checkpoint**: Application fully deployed to Kubernetes, all CRUD operations working, scaling validated

---

## Phase 4: User Story 3 - AI-Assisted Operations (Priority: P3)

**Goal**: Integrate kubectl-ai, kagent, and Gordon for intelligent Kubernetes operations

**Independent Test**: Use kubectl-ai to diagnose issues, kagent to analyze cluster health, Gordon to optimize images

- [ ] T091 [P] [US3] Create deployment script scripts/deploy.sh using kubectl-ai for deployment
- [ ] T092 [P] [US3] Create diagnostics script scripts/diagnostics.sh wrapping kubectl-ai and kagent commands
- [ ] T093 [P] [US3] Create validation script scripts/validate.sh for pre-deployment checks
- [ ] T094 [US3] Test kubectl-ai pod status check: `kubectl ai "check status of all todo pods"`
- [ ] T095 [US3] Test kubectl-ai diagnostics: `kubectl ai "why is pod todo-backend-xxx not starting"`
- [ ] T096 [US3] Test kubectl-ai scaling recommendation: `kubectl ai "should I scale todo-backend based on current load"`
- [ ] T097 [US3] Test kagent cluster health analysis: `kagent analyze`
- [ ] T098 [US3] Test kagent resource utilization: `kagent resources`
- [ ] T099 [US3] Test kagent optimization recommendations: `kagent diagnose`
- [ ] T100 [US3] Simulate CrashLoopBackOff scenario and use kubectl-ai to diagnose
- [ ] T101 [US3] Use kubectl-ai to get remediation steps for common issues
- [ ] T102 [US3] Use Gordon to analyze frontend Dockerfile: `docker gordon analyze frontend/Dockerfile`
- [ ] T103 [US3] Use Gordon to optimize frontend Dockerfile based on recommendations
- [ ] T104 [US3] Use Gordon to analyze backend Dockerfile: `docker gordon analyze backend/Dockerfile`
- [ ] T105 [US3] Use Gordon to optimize backend Dockerfile based on recommendations
- [ ] T106 [US3] Rebuild images with Gordon optimizations and verify size reduction
- [ ] T107 [US3] Document kubectl-ai commands in scripts/diagnostics.sh
- [ ] T108 [US3] Document kagent commands in scripts/diagnostics.sh
- [ ] T109 [US3] Add kubectl-ai usage examples to deployment documentation
- [ ] T110 [US3] Add kagent usage examples to deployment documentation

**Checkpoint**: AI-assisted tools integrated and validated for operational efficiency

---

## Phase 5: User Story 4 - Observability and Monitoring (Priority: P4)

**Goal**: Implement structured logging and health monitoring for operational visibility

**Independent Test**: Generate application events, verify JSON logs, check health endpoints respond correctly

- [ ] T111 [P] [US4] Install Winston for structured logging in frontend: `npm install winston`
- [ ] T112 [P] [US4] Install structlog for structured logging in backend: `pip install structlog`
- [ ] T113 [P] [US4] Configure Winston JSON formatter in frontend/src/lib/logger.ts
- [ ] T114 [P] [US4] Configure structlog JSON renderer in backend/src/lib/logger.py
- [ ] T115 [P] [US4] Add timestamp processor to frontend logger
- [ ] T116 [P] [US4] Add timestamp processor to backend logger
- [ ] T117 [P] [US4] Add trace_id to frontend log context
- [ ] T118 [P] [US4] Add trace_id to backend log context
- [ ] T119 [P] [US4] Add service name to frontend logs (service: "todo-frontend")
- [ ] T120 [P] [US4] Add service name to backend logs (service: "todo-backend")
- [ ] T121 [US4] Update frontend health endpoint to return detailed status with dependencies
- [ ] T122 [US4] Update backend health endpoint to return detailed status with database connection
- [ ] T123 [US4] Update frontend readiness endpoint to check backend connectivity
- [ ] T124 [US4] Update backend readiness endpoint to check database connection pool
- [ ] T125 [US4] Add structured error logging to frontend API client
- [ ] T126 [US4] Add structured error logging to backend exception handlers
- [ ] T127 [US4] Add request/response logging middleware to frontend
- [ ] T128 [US4] Add request/response logging middleware to backend
- [ ] T129 [US4] Test log format: `kubectl logs -l app=todo-frontend | jq .`
- [ ] T130 [US4] Test log format: `kubectl logs -l app=todo-backend | jq .`
- [ ] T131 [US4] Verify logs contain timestamp, service, severity, trace_id fields
- [ ] T132 [US4] Test health endpoint returns 200 OK: `curl http://localhost:8000/health`
- [ ] T133 [US4] Test readiness endpoint returns 200 OK: `curl http://localhost:8000/ready`
- [ ] T134 [US4] Simulate error and verify structured error log with context
- [ ] T135 [US4] Verify liveness probes are passing: `kubectl describe pod -l app=todo-backend`
- [ ] T136 [US4] Verify readiness probes are passing: `kubectl describe pod -l app=todo-frontend`
- [ ] T137 [US4] Test log aggregation with kubectl: `kubectl logs -l app=todo-backend --tail=100 | jq 'select(.severity=="error")'`
- [ ] T138 [US4] Document log format and fields in deployment documentation
- [ ] T139 [US4] Document health check endpoints in deployment documentation

**Checkpoint**: Structured logging implemented, health checks validated, operational visibility achieved

---

## Phase 6: User Story 5 - Deployment Documentation (Priority: P5)

**Goal**: Create comprehensive deployment documentation for self-service deployment

**Independent Test**: New developer follows documentation to deploy from scratch successfully

- [ ] T140 [P] [US5] Create README.md at repository root with deployment overview
- [ ] T141 [P] [US5] Document prerequisites in README.md (Docker, Minikube, Helm, kubectl-ai, kagent)
- [ ] T142 [P] [US5] Document environment setup steps in README.md
- [ ] T143 [P] [US5] Document Minikube cluster setup in README.md
- [ ] T144 [P] [US5] Document Docker image building steps in README.md
- [ ] T145 [P] [US5] Document Kubernetes secrets creation in README.md
- [ ] T146 [P] [US5] Document Helm chart deployment steps in README.md
- [ ] T147 [P] [US5] Document validation and testing steps in README.md
- [ ] T148 [P] [US5] Document scaling instructions in README.md
- [ ] T149 [P] [US5] Document troubleshooting common issues in README.md
- [ ] T150 [P] [US5] Add kubectl-ai usage examples to README.md
- [ ] T151 [P] [US5] Add kagent usage examples to README.md
- [ ] T152 [P] [US5] Add Gordon optimization examples to README.md
- [ ] T153 [P] [US5] Document rolling update procedure in README.md
- [ ] T154 [P] [US5] Document rollback procedure in README.md
- [ ] T155 [P] [US5] Document cleanup procedure in README.md
- [ ] T156 [P] [US5] Add architecture diagram to README.md showing components
- [ ] T157 [P] [US5] Add deployment flow diagram to README.md
- [ ] T158 [P] [US5] Create DEPLOYMENT.md with detailed step-by-step guide
- [ ] T159 [P] [US5] Create TROUBLESHOOTING.md with common issues and solutions
- [ ] T160 [US5] Validate documentation by having a new developer follow it
- [ ] T161 [US5] Measure time to deploy from documentation (target: < 30 minutes)
- [ ] T162 [US5] Update documentation based on validation feedback
- [ ] T163 [US5] Add quick reference section with common commands
- [ ] T164 [US5] Add FAQ section addressing common questions

**Checkpoint**: Comprehensive documentation complete, validated by new developer deployment

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, optimization, and production readiness

- [ ] T165 [P] Create values-dev.yaml for development environment in helm/frontend/
- [ ] T166 [P] Create values-dev.yaml for development environment in helm/backend/
- [ ] T167 [P] Create values-prod.yaml template for production in helm/frontend/
- [ ] T168 [P] Create values-prod.yaml template for production in helm/backend/
- [ ] T169 [P] Add Ingress template to helm/frontend/templates/ingress.yaml (optional)
- [ ] T170 [P] Add Ingress template to helm/backend/templates/ingress.yaml (optional)
- [ ] T171 Validate all success criteria from spec.md are met
- [ ] T172 Run reproducibility test: delete cluster, redeploy from scratch
- [ ] T173 Measure deployment time end-to-end (target: < 5 minutes)
- [ ] T174 Measure pod startup time (target: < 2 minutes)
- [ ] T175 Verify frontend image size < 200MB
- [ ] T176 Verify backend image size < 150MB
- [ ] T177 Load test with 100 concurrent users
- [ ] T178 Verify 99.9% uptime during rolling update
- [ ] T179 Verify zero secrets in container images
- [ ] T180 Verify all containers run as non-root
- [ ] T181 Run security scan on container images
- [ ] T182 Validate HPA triggers correctly under load
- [ ] T183 Test complete disaster recovery (delete all resources, redeploy)
- [ ] T184 Create deployment checklist for production readiness
- [ ] T185 Final review of all Helm charts for best practices
- [ ] T186 Final review of all Dockerfiles for optimization
- [ ] T187 Update .env.example with all required variables
- [ ] T188 Update k8s-secrets.yaml.example with all required secrets
- [ ] T189 Create CHANGELOG.md documenting Phase IV changes
- [ ] T190 Tag release v1.0.0 for Phase IV completion

**Checkpoint**: Phase IV complete, production-ready Kubernetes deployment validated

---

## Dependencies

### User Story Completion Order

```
Phase 1 (Setup)
    ↓
Phase 2 (US2: Container Packaging) ← FOUNDATIONAL
    ↓
Phase 3 (US1: Kubernetes Deployment) ← MVP
    ↓
Phase 4 (US3: AI-Assisted Operations) ← Independent
    ↓
Phase 5 (US4: Observability) ← Independent
    ↓
Phase 6 (US5: Documentation) ← Independent
    ↓
Phase 7 (Polish)
```

**Critical Path**: Setup → Container Packaging (US2) → Kubernetes Deployment (US1)

**Parallel Opportunities**: After US1 is complete, US3, US4, and US5 can be implemented in parallel

### External Dependencies

- Docker Desktop installed and running
- Minikube with 4 CPU, 8GB RAM minimum
- Helm 3.x installed
- kubectl-ai installed via krew
- kagent installed
- Neon PostgreSQL accessible from Minikube
- Cohere API key available
- Internet connectivity for pulling base images

### Internal Dependencies

- Phase III application code (frontend and backend) must be functional
- Better Auth JWT authentication must be working
- MCP tools implementation must be complete
- Database schema and migrations must be applied

---

## Parallel Execution Examples

### Phase 2 (Container Packaging) - Parallel Tasks

```bash
# Terminal 1: Frontend Dockerfile and health endpoints
T013, T015, T017, T018

# Terminal 2: Backend Dockerfile and health endpoints
T014, T016, T019, T020

# After both complete, build and test in sequence
T021-T032
```

### Phase 3 (Kubernetes Deployment) - Parallel Tasks

```bash
# Terminal 1: Frontend Helm chart
T033, T035, T037, T039, T041, T043, T045

# Terminal 2: Backend Helm chart
T034, T036, T038, T040, T042, T044, T046

# After both complete, configure and deploy in sequence
T047-T090
```

### Phase 4 (AI Operations) - Parallel Tasks

```bash
# Terminal 1: Scripts creation
T091, T092, T093

# Terminal 2: kubectl-ai testing
T094-T096

# Terminal 3: kagent testing
T097-T099

# Terminal 4: Gordon optimization
T102-T106
```

### Phase 5 (Observability) - Parallel Tasks

```bash
# Terminal 1: Frontend logging
T111, T113, T115, T117, T119

# Terminal 2: Backend logging
T112, T114, T116, T118, T120

# After both complete, test in sequence
T129-T139
```

### Phase 6 (Documentation) - Parallel Tasks

```bash
# All documentation tasks (T140-T164) can be done in parallel
# by different team members working on different sections
```

---

## Implementation Strategy

### MVP Scope (Minimum Viable Product)

**Recommended MVP**: Phase 1 + Phase 2 + Phase 3 (US1)

This delivers:
- ✅ Containerized application
- ✅ Kubernetes deployment to Minikube
- ✅ Helm-managed infrastructure
- ✅ Health checks and scaling
- ✅ End-to-end functionality validation

**Time Estimate**: 2-3 days for experienced developer

### Incremental Delivery

1. **Week 1**: MVP (Phases 1-3)
   - Deploy to Kubernetes
   - Validate core functionality

2. **Week 2**: AI Operations (Phase 4)
   - Integrate kubectl-ai, kagent, Gordon
   - Optimize operations

3. **Week 3**: Observability + Documentation (Phases 5-6)
   - Structured logging
   - Comprehensive documentation

4. **Week 4**: Polish (Phase 7)
   - Production readiness
   - Security hardening
   - Performance optimization

---

## Validation Checklist

Before marking Phase IV complete, verify:

- [ ] All 20 functional requirements (FR-001 to FR-020) are satisfied
- [ ] All 15 success criteria (SC-001 to SC-015) are met
- [ ] All 5 user stories are independently testable
- [ ] All edge cases are handled gracefully
- [ ] Documentation is complete and validated
- [ ] Reproducibility test passes (clean deployment from scratch)
- [ ] Security scan passes (no secrets in images, non-root containers)
- [ ] Performance targets met (deployment < 5 min, pods ready < 2 min)
- [ ] All AI DevOps tools (kubectl-ai, kagent, Gordon) are functional

---

**Total Tasks**: 190
**Parallelizable Tasks**: 89 (47%)
**User Stories**: 5 (US1-US5)
**Estimated Duration**: 3-4 weeks for complete implementation
**MVP Duration**: 2-3 days (Phases 1-3)

**Status**: Ready for implementation
**Next Step**: Begin Phase 1 (Setup) tasks
