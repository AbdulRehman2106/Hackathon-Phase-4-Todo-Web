---
id: 002
title: Phase IV Kubernetes Deployment Plan
stage: plan
date: 2026-02-16
surface: agent
model: claude-sonnet-4-5
feature: k8s-deployment
branch: 003-k8s-deployment
user: system
command: /sp.plan
labels: ["kubernetes", "deployment", "helm", "docker", "minikube", "ai-devops", "kubectl-ai", "kagent", "gordon"]
links:
  spec: specs/003-k8s-deployment/spec.md
  ticket: null
  adr: null
  pr: null
files:
 - specs/003-k8s-deployment/plan.md
 - specs/003-k8s-deployment/research.md
 - specs/003-k8s-deployment/data-model.md
 - specs/003-k8s-deployment/quickstart.md
 - specs/003-k8s-deployment/contracts/frontend-values.yaml
 - specs/003-k8s-deployment/contracts/backend-values.yaml
 - specs/003-k8s-deployment/contracts/secrets-template.yaml
tests:
 - Constitution Check: All 8 principles validated (PASS)
 - Technical Context: All NEEDS CLARIFICATION resolved
 - Resource Sizing: Validated against Minikube constraints
---

## Prompt

```text
# SP.PLAN
# Project: Cloud-Native AI Todo Chatbot
# Phase IV: Local Kubernetes Deployment with AI DevOps

You are to generate a detailed **implementation plan** for Phase IV.

--------------------------------------------------
I. OBJECTIVE
--------------------------------------------------

Deploy the Phase III Todo Chatbot locally using **Minikube, Helm, Docker Desktop, Gordon, kubectl-ai, and Kagent** with:

- AI Todo Chatbot fully operational
- Cohere API integrated
- OpenAI Agents SDK functional via Cohere API
- Stateless backend and persistent database (Neon PostgreSQL)
- AI-assisted containerization and Kubernetes orchestration
- Secure handling of secrets and environment variables

All deployment steps must follow **Spec-Driven Development**, reproducible, and no manual ad-hoc steps.

--------------------------------------------------
II. PHASE IV TASK BREAKDOWN
--------------------------------------------------

1. **Environment Preparation**
   - Verify Docker Desktop installation
   - Enable Gordon (Docker AI Agent)
   - Install Minikube and start local cluster
   - Install Helm
   - Install kubectl-ai & kagent
   - Verify kubectl context

2. **Containerization (Docker + Gordon)**
   - Build frontend Docker image
   - Build backend Docker image (includes AI Todo Chatbot)
   - Use multi-stage Dockerfiles
   - Push images to local registry or Docker Desktop

3. **Helm Chart Creation**
   - Create **frontend Helm chart**
     - Deployment, Service, ConfigMap/Secret, HPA
   - Create **backend Helm chart**
     - Deployment, Service, ConfigMap/Secret, HPA
   - Values.yaml must include:
     - image repository & tag
     - replicaCount
     - environment variables (including Cohere API key)
     - resource limits and requests
     - probes (liveness, readiness)

4. **AI Integration**
   - Configure backend to use **Cohere API** for NLP tasks
   - Integrate OpenAI Agents SDK code through Cohere API
   - Verify AI Todo Chatbot handles:
     - Add / delete / update / list tasks
     - Natural language understanding
     - User-specific tasks via Better Auth
   - Map AI tool calls to MCP tools in backend

5. **Deployment**
   - Deploy Helm charts for frontend & backend
     - Using **kubectl-ai** commands
   - Validate Pods running, Services reachable
   - Test Chatbot interactions
   - Scale replicas if needed using kubectl-ai or Kagent
   - Verify HPA triggers correctly

6. **Observability & Diagnostics**
   - Configure structured logging (JSON, timestamped)
   - Use kubectl-ai / kagent to check cluster health
   - Include scripts for:
     - Pod status
     - Resource utilization
     - Error logs
   - Ensure errors are graceful and informative

7. **Documentation & Validation**
   - README for:
     - Setup
     - Deployment
     - Testing
     - Scaling
   - Validate all tasks against **sp.specify** success criteria
   - Run reproducibility checks (deploy clean cluster, repeat deployment)

--------------------------------------------------
III. DEPENDENCIES
--------------------------------------------------

- Backend container must include AI Todo Chatbot and Cohere integration before deployment
- Database (Neon PostgreSQL) must be available
- Helm charts depend on successful Docker image builds
- AI Agents SDK code must be tested locally before deployment
- kubectl-ai and kagent require cluster to be running
- Secrets and environment variables must be configured before deployment

--------------------------------------------------
IV. SUCCESS CRITERIA
--------------------------------------------------

Phase IV is complete when:

1. Frontend and backend deployed on Minikube via Helm
2. Docker images built and used by Helm charts
3. AI Todo Chatbot functional with Cohere API
4. OpenAI Agents SDK calls work through Cohere API
5. Stateless server persists data to Neon PostgreSQL
6. kubectl-ai and Kagent successfully manage scaling & diagnostics
7. Logs structured, readable, and errors handled gracefully
8. Deployment reproducible from scratch with no manual steps
9. All sp.specify constraints are satisfied

--------------------------------------------------
V. CONSTRAINTS
--------------------------------------------------

- No manual `kubectl apply` outside AI-assisted workflow
- Secrets and API keys must be managed via Kubernetes Secrets
- No hardcoded credentials
- Multi-stage Dockerfiles mandatory
- Must follow Spec-Driven Development and Claude Code instructions

--------------------------------------------------
VI. TIMELINE (RECOMMENDED)
--------------------------------------------------

- Day 1: Environment setup (Docker, Minikube, Helm, kubectl-ai, Kagent)
- Day 2: Containerization with Gordon
- Day 3: Helm chart creation
- Day 4: AI integration testing
- Day 5: Minikube deployment & scaling tests
- Day 6: Observability, logging, diagnostics, documentation

--------------------------------------------------

This plan is binding and must be followed by all Claude Code agents and skills for Phase IV.
```

## Response snapshot

Generated comprehensive Phase IV implementation plan with:

**Phase 0: Research & Technology Decisions**
- Resolved 10 technology decisions with rationale and alternatives
- Docker base images: node:20-alpine (frontend), python:3.11-slim (backend)
- Helm chart structure: Separate charts for independent scaling
- Secrets management: Kubernetes native Secrets
- No service mesh (unnecessary for 2 services)
- Minikube ingress addon (NGINX)
- Local Docker Desktop registry
- HTTP health probes (/health, /ready)
- Guaranteed QoS (requests = limits)
- CPU-based HPA (80% target)
- Structured JSON logging to stdout

**Phase 1: Design & Contracts**
- Created data-model.md: Complete Kubernetes resource specifications
  - Container images with multi-stage builds
  - Deployments with rolling update strategy
  - Services (ClusterIP)
  - ConfigMaps and Secrets
  - HPA configuration
  - Ingress (optional)
- Created contracts/:
  - frontend-values.yaml: Helm values schema with constraints
  - backend-values.yaml: Helm values schema with environment mapping
  - secrets-template.yaml: Secret creation instructions
- Created quickstart.md: 30-minute deployment guide
  - Prerequisites installation
  - Minikube cluster setup
  - Image building with Gordon
  - Secret creation
  - Helm deployment
  - Verification and testing
  - Troubleshooting guide

**Constitution Check**: ✅ All 8 principles validated
- Spec-Driven Development: Complete spec exists
- Agentic Workflow: kubectl-ai, kagent, Gordon mandatory
- Separation of Concerns: Separate containers, clear boundaries
- Security by Design: Kubernetes Secrets, non-root containers
- UI/UX Excellence: Inherited from Phase III
- Stateless AI Architecture: PostgreSQL persistence
- Cloud-Native First: Full containerization, health probes
- AI-Augmented DevOps: AI tools for all operations

**Resource Sizing**:
- Frontend: 100m-500m CPU, 256Mi-512Mi memory, 2-5 replicas
- Backend: 250m-1000m CPU, 512Mi-1Gi memory, 2-5 replicas
- Minikube requirements: 4 CPU, 8GB RAM minimum

**Updated agent context** with Phase IV technologies.

## Outcome

- ✅ Impact: Complete implementation plan ready for task generation
- 🧪 Tests: Constitution validation (8/8 PASS), resource constraints validated
- 📁 Files: 7 artifacts created (plan.md, research.md, data-model.md, quickstart.md, 3 contracts)
- 🔁 Next prompts: Run `/sp.tasks` to generate implementation tasks
- 🧠 Reflection: Plan comprehensively addresses containerization, Kubernetes deployment, and AI DevOps integration with clear technology decisions and rationale

## Evaluation notes (flywheel)

- Failure modes observed: None - all constitution gates passed
- Graders run and results (PASS/FAIL): Constitution Check (PASS), Technical Context Resolution (PASS), Resource Sizing (PASS)
- Prompt variant (if applicable): Standard /sp.plan workflow
- Next experiment (smallest change to try): Generate tasks.md with /sp.tasks command

## Architectural Decisions Detected

📋 **Architectural decision detected**: Container base image selection (Alpine vs Slim vs Distroless for frontend/backend)
   Document reasoning and tradeoffs? Run `/sp.adr container-base-images`

📋 **Architectural decision detected**: Kubernetes package management (Helm vs Kustomize vs raw YAML)
   Document reasoning and tradeoffs? Run `/sp.adr kubernetes-package-management`

📋 **Architectural decision detected**: Secrets management strategy (K8s Secrets vs Sealed Secrets vs External Secrets Operator vs Vault)
   Document reasoning and tradeoffs? Run `/sp.adr secrets-management-strategy`
