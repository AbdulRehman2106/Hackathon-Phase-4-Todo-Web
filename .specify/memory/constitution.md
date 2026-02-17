<!--
Sync Impact Report:
- Version Change: 1.1.0 → 2.0.0
- Modified Principles:
  - Principle II: Agentic Workflow expanded to include AI DevOps tools (kubectl-ai, kagent, Gordon)
  - Technology Stack expanded to include Docker, Kubernetes, Helm, Minikube
- Added Sections:
  - Principle VII: Cloud-Native First (containerization, stateless design)
  - Principle VIII: AI-Augmented DevOps (kubectl-ai, kagent, Gordon preference)
  - Section: Containerization Governance
  - Section: Kubernetes Governance
  - Section: AI DevOps Workflow
  - Section: Deployment Flow
  - Section: Failure Handling Protocol
  - Section: Scalability Preparation
  - Expanded Prohibitions section
  - Expanded Success Criteria for Phase IV
- Removed Sections: None
- Templates Status:
  ✅ spec-template.md - requires validation for infrastructure requirements
  ✅ plan-template.md - requires validation for deployment planning
  ✅ tasks-template.md - requires validation for containerization/K8s tasks
  ⚠ commands/*.md - may need updates for kubectl-ai/kagent references
- Follow-up TODOs:
  - Validate all templates align with Phase IV requirements
  - Ensure command files reference AI DevOps tools appropriately
- Rationale for MAJOR version bump:
  - Backward-incompatible architectural change (monolithic → cloud-native)
  - Mandatory containerization and Kubernetes deployment
  - New infrastructure governance requirements
  - Fundamental change in deployment model
-->

# Cloud-Native AI Todo Chatbot Constitution
## Phase IV: Local Kubernetes Deployment with AI DevOps

## Core Principles

### I. Spec-Driven Development (NON-NEGOTIABLE)

All implementation MUST follow written specifications. No code changes are permitted without a corresponding specification document that defines requirements, acceptance criteria, and expected behavior. All infrastructure must be defined before deployment.

**Rationale**: Ensures traceability, prevents scope creep, and maintains alignment between business requirements and technical implementation. Specifications serve as the single source of truth for what should be built. Infrastructure-as-code requires the same rigor as application code.

**Rules**:
- Every feature MUST have a spec.md before implementation begins
- Specs MUST include clear acceptance criteria
- Implementation MUST NOT deviate from approved specs without amendment
- Changes to specs require explicit approval and version tracking
- Infrastructure specifications MUST precede deployment
- No direct implementation without written specification

### II. Agentic Workflow (NON-NEGOTIABLE)

No manual coding is permitted outside structured agentic workflow. All code changes, file operations, infrastructure operations, and development tasks MUST be performed via Claude Code agents and AI DevOps tools following defined workflows.

**Rationale**: Ensures consistency, auditability, and adherence to established patterns. Prevents ad-hoc changes that bypass quality gates and documentation requirements. AI-augmented DevOps reduces human error and improves reproducibility.

**Rules**:
- All code generation via Claude Code agents
- Manual file edits are prohibited
- Agent actions MUST be traceable via PHRs (Prompt History Records)
- Workflow deviations require explicit justification
- Prefer kubectl-ai over raw kubectl commands
- Prefer kagent for cluster diagnostics
- Prefer Gordon (Docker AI) for container operations
- No manual kubectl apply without AI validation

### III. Separation of Concerns

Frontend, backend, authentication, database, and AI layers MUST be clearly decoupled with well-defined interfaces. Each component runs in its own container with no tight coupling.

**Rationale**: Enables independent development, testing, scaling, and deployment of each layer. Reduces coupling and improves maintainability. Essential for cloud-native architecture.

**Rules**:
- Frontend communicates with backend only via REST API
- Backend accesses database only via SQLModel ORM
- Authentication handled by dedicated service (Better Auth)
- AI chatbot interacts with system exclusively via MCP tools
- No direct database session sharing between layers
- Each layer has clear, documented contracts
- Frontend runs in separate container
- Backend runs in separate container
- AI service logic inside backend container
- No tight coupling between containers

### IV. Security by Design (NON-NEGOTIABLE)

User isolation and task ownership MUST be enforced at all layers. Every request MUST be authenticated and authorized before processing. No API keys in code. Kubernetes secrets for all sensitive data.

**Rationale**: Prevents unauthorized access, data leakage, and privilege escalation. Security cannot be retrofitted; it must be built into the architecture from the start. Container security is critical in cloud-native environments.

**Rules**:
- Backend MUST verify JWT on every request
- Tasks MUST always be scoped to the authenticated user
- No user can access another user's data
- All secrets via Kubernetes Secrets (no hardcoding)
- Database queries MUST include user_id filters for user-scoped resources
- AI tool calls MUST validate user authorization before execution
- No cross-user task visibility in AI responses
- .env files MUST be converted to Kubernetes Secrets
- Enforce least privilege RBAC
- No privileged containers
- No root user inside containers

### V. UI/UX Excellence

Frontend MUST be visually polished, accessible, and professional. The application should feel production-ready, not like a prototype or placeholder.

**Rationale**: User experience directly impacts adoption and satisfaction. A well-designed interface reduces cognitive load and increases productivity.

**Rules**:
- Clean, modern, minimal design language
- Consistent spacing, typography scale, and color system
- Clear visual hierarchy for task states (pending vs completed)
- Responsive design: mobile, tablet, desktop
- Accessibility basics: readable contrast, focus states, semantic HTML
- No placeholder-looking UI elements
- AI chat interface integrated seamlessly into dashboard

### VI. Stateless AI Architecture (NON-NEGOTIABLE)

AI chatbot MUST operate in a stateless manner with all conversation context persisted in PostgreSQL. Every request must be independently reproducible without in-memory state. Stateless application containers are mandatory.

**Rationale**: Enables horizontal scaling, zero-downtime deployments, and resilience to server restarts. Stateless architecture is essential for production-grade AI systems and cloud-native applications.

**Rules**:
- No in-memory conversation state storage
- All conversation context persisted in database
- AI MUST interact with system exclusively via MCP tools
- No direct database manipulation by LLM
- Tools serve as strict execution boundary
- Every request independently reproducible
- Conversation must resume correctly after server restart
- All application containers must be stateless
- Environment-based configuration only

### VII. Cloud-Native First (NON-NEGOTIABLE)

All services MUST be containerized. Application design MUST support horizontal scaling, health checks, and graceful shutdown. Infrastructure MUST be reproducible and version-controlled.

**Rationale**: Cloud-native architecture enables scalability, resilience, and portability. Containerization ensures consistency across environments. Kubernetes orchestration provides production-grade deployment capabilities.

**Rules**:
- All services containerized via Docker
- Use multi-stage Docker builds for optimization
- Minimal base images (Alpine, slim variants)
- No hardcoded secrets in containers
- Image tags MUST be versioned
- All builds MUST be reproducible
- Stateless application containers
- Environment-based configuration
- Health checks (liveness and readiness probes) required
- Graceful shutdown handling
- Resource limits defined for all containers

### VIII. AI-Augmented DevOps (NON-NEGOTIABLE)

Prefer AI-powered DevOps tools over manual operations. kubectl-ai for Kubernetes operations, kagent for diagnostics, Gordon for Docker operations. No blind redeployments without AI-assisted diagnosis.

**Rationale**: AI-augmented DevOps reduces human error, improves troubleshooting speed, and ensures consistent operations. AI tools provide intelligent recommendations and catch common mistakes.

**Rules**:
- Prefer kubectl-ai over raw kubectl commands
- Prefer kagent for cluster health analysis
- Prefer Gordon (Docker AI) for container operations
- Use AI tools for diagnostics before manual intervention
- No blind redeployments allowed
- CrashLoopBackOff MUST trigger AI diagnostic workflow
- All infrastructure operations MUST be traceable
- AI DevOps workflow MUST be followed (spec → plan → tasks → implement → validate → optimize)

## UI & UX Standards

### Design Language
- **Typography**: Consistent scale (e.g., 12px, 14px, 16px, 20px, 24px, 32px)
- **Spacing**: 4px base unit (4, 8, 12, 16, 24, 32, 48, 64)
- **Colors**: Defined palette with semantic naming (primary, secondary, success, warning, error, neutral)
- **Components**: Reusable, composable, with clear states (default, hover, active, disabled, loading)

### Interaction Patterns
- Loading states for all async operations
- Error messages that are clear and actionable
- Confirmation dialogs for destructive actions
- Keyboard navigation support
- Touch-friendly targets (minimum 44x44px)
- AI chat interface with typing indicators and message history

### Accessibility Requirements
- WCAG 2.1 Level AA contrast ratios
- Semantic HTML structure
- ARIA labels where needed
- Focus indicators visible and clear
- Screen reader friendly

## Technology Stack & Constraints

### Frontend
- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS
- **Authentication**: Better Auth (JWT-based)
- **State Management**: React hooks, Server Components where appropriate
- **AI Chat UI**: Integrated within dashboard
- **Container**: Separate Docker container
- **Port**: 3000

### Backend
- **Framework**: FastAPI
- **ORM**: SQLModel
- **Authentication**: JWT verification
- **API Style**: REST with JSON payloads
- **AI Orchestration**: OpenAI Agents SDK (adapted for Cohere)
- **MCP Tools**: Official MCP SDK for tool exposure
- **Container**: Separate Docker container
- **Port**: 8000

### AI & LLM
- **LLM Provider**: Cohere API
- **Orchestration**: OpenAI Agents SDK (modified to use Cohere endpoints)
- **Tool Architecture**: MCP (Model Context Protocol)
- **Model Requirements**: Tool-calling support, structured output, temperature 0.2-0.4
- **Token Monitoring**: All API calls logged with token usage

### Database
- **Provider**: Neon Serverless PostgreSQL (or PostgreSQL in Kubernetes)
- **Access Pattern**: SQLModel ORM only (no raw SQL)
- **Migrations**: Alembic or equivalent
- **AI Tables**: conversations, messages (in addition to tasks)

### Infrastructure
- **Container Runtime**: Docker Desktop
- **Orchestration**: Kubernetes (Minikube for local)
- **Package Manager**: Helm Charts
- **Service Type**: ClusterIP (internal), optional Ingress
- **Namespace Isolation**: Environment-based namespaces

### AI DevOps Tools
- **Docker AI**: Gordon (for container operations)
- **Kubernetes AI**: kubectl-ai (for cluster operations)
- **Diagnostics**: kagent (for cluster health analysis)

### Security
- **Authentication**: Better Auth with JWT tokens
- **Authorization**: User-scoped queries enforced at database layer
- **Secrets Management**: Kubernetes Secrets (no .env in containers)
- **API Keys**: COHERE_API_KEY stored in Kubernetes Secret
- **RBAC**: Least privilege service accounts

## Containerization Governance

### Docker Build Requirements
- Use multi-stage Docker builds for optimization
- Minimal base images (node:20-alpine, python:3.11-slim)
- No hardcoded secrets in Dockerfiles
- .env files MUST be converted to Kubernetes Secrets
- Image tags MUST be versioned (git SHA or semantic version)
- All builds MUST be reproducible
- .dockerignore MUST exclude unnecessary files

### Image Optimization
- Frontend image target: < 200MB
- Backend image target: < 150MB
- Use layer caching effectively
- Combine RUN commands to reduce layers
- Remove build dependencies in final stage

### Security Requirements
- Non-root user in containers
- Read-only root filesystem where possible
- No privileged containers
- Scan images for vulnerabilities
- Use official base images only

## Kubernetes Governance

### Deployment Requirements
- All deployments MUST use Helm charts
- No raw YAML apply unless generated by tools
- Each service MUST define:
  - Resource limits (CPU and memory)
  - Liveness probe (health check)
  - Readiness probe (traffic routing)
  - Replica count (minimum 2 for backend)
- Autoscaling MUST be HPA-ready
- Rolling update strategy with max surge and max unavailable defined

### Service Configuration
- Frontend: ClusterIP service, port 3000
- Backend: ClusterIP service, port 8000
- Optional: Ingress for external access
- Service mesh: Optional (Istio/Linkerd)

### Resource Management
- CPU requests and limits defined
- Memory requests and limits defined
- Storage: PersistentVolumeClaims for stateful data
- Resource quotas per namespace

### Health Checks
- Liveness probe: Detects unhealthy containers (restart)
- Readiness probe: Controls traffic routing
- Startup probe: Handles slow-starting applications
- Probe endpoints: /health (liveness), /ready (readiness)

### Namespace Strategy
- Development: dev namespace
- Staging: staging namespace
- Production: production namespace
- Isolation enforced via NetworkPolicies

## AI Chatbot Standards

### Tool Governance

**Approved MCP Tools**:
- `add_task` - Creates new task for authenticated user
- `list_tasks` - Retrieves tasks filtered by user_id
- `complete_task` - Marks task as completed
- `delete_task` - Permanently removes task
- `update_task` - Modifies existing task

**Tool Rules**:
- All mutations require authenticated user_id
- list_tasks MUST filter by user_id
- No bulk destructive operations
- All tool responses logged
- Tool output MUST be structured JSON
- Tool output MUST include operation status
- Tool output MUST NOT expose database schema

### Conversation Persistence

**Database Tables**:
- `tasks` - User tasks
- `conversations` - Conversation sessions
- `messages` - Individual messages (user and assistant)

**Persistence Rules**:
- Store every user message before AI execution
- Store every assistant response after execution
- Maintain strict chronological ordering
- Conversation MUST resume after server restart
- No in-memory caching of conversations

### Cohere Integration Requirements

**API Integration**:
- Replace default OpenAI model calls with Cohere API calls
- Agents SDK MUST use Cohere chat/completion endpoint internally
- Tool call structure MUST remain compatible with Agents SDK format
- Ensure JSON-mode output enforcement
- Implement retry logic for rate limits and transient failures
- Token usage MUST be monitored and logged
- API key stored in Kubernetes Secret

**Model Configuration**:
- Temperature: 0.2-0.4 (deterministic responses)
- Must support tool-calling pattern
- Must support structured output
- No hallucinated task IDs or database entries

### Error Handling Standards

**Must Gracefully Handle**:
- Task not found
- Invalid task_id
- Cohere API failure
- Rate limiting
- MCP tool validation failure
- Unauthorized access

**Error Response Requirements**:
- User-friendly messages (no stack traces)
- Suggest corrective action
- Log internally with severity levels
- No exposure of internal system details

### Performance Requirements

**Response Time**:
- Target < 2.5 seconds per AI request

**Scalability**:
- Must support horizontal scaling
- No session locking
- No memory-based caching of conversations

**Observability**:
- Log all tool calls
- Log Cohere API latency
- Log token usage
- Log errors with severity levels
- Structured JSON logging

## AI DevOps Workflow

Deployment MUST follow this sequence (no steps may be skipped):

1. **Write Specification**
   - Document requirements in specs/<feature>/spec.md
   - Define infrastructure requirements
   - Specify containerization needs
   - Define Kubernetes resources

2. **Generate Plan**
   - Architecture decisions in specs/<feature>/plan.md
   - Containerization strategy
   - Kubernetes deployment design
   - Helm chart structure

3. **Break into Tasks**
   - Granular tasks in specs/<feature>/tasks.md
   - Dependency-aware breakdown
   - Include containerization tasks
   - Include deployment tasks

4. **Implement using Claude Code**
   - Execute tasks via agents
   - Generate Dockerfiles
   - Generate Helm charts
   - Create Kubernetes manifests

5. **Validate with kubectl-ai**
   - Use kubectl-ai for deployment validation
   - Verify pod health
   - Check service endpoints
   - Validate resource allocation

6. **Optimize with kagent**
   - Run cluster health analysis
   - Identify resource bottlenecks
   - Optimize configurations
   - Implement recommendations

## Deployment Flow

1. **Build Images via Gordon**
   - Use Docker AI (Gordon) for image builds
   - Optimize Dockerfiles
   - Tag images with version
   - Validate image size

2. **Validate Locally**
   - Test containers locally
   - Verify environment variables
   - Check health endpoints
   - Test inter-container communication

3. **Generate Helm Charts**
   - Create Chart.yaml
   - Define values.yaml
   - Generate templates (deployment, service, ingress)
   - Configure environment-specific values

4. **Deploy to Minikube**
   - Start Minikube cluster
   - Enable required addons (ingress, metrics-server)
   - Install Helm chart
   - Verify deployment

5. **Validate Pods**
   - Check pod status (Running)
   - Verify replica count
   - Test liveness probes
   - Test readiness probes

6. **Test AI Chatbot Functionality**
   - Test all MCP tools
   - Verify user isolation
   - Test conversation persistence
   - Validate Cohere API integration

7. **Run Health Analysis**
   - Use kagent for cluster diagnostics
   - Check resource utilization
   - Identify optimization opportunities
   - Document findings

## Failure Handling Protocol

If pods fail, follow this diagnostic workflow:

1. **Use kubectl-ai to Diagnose**
   - Generate diagnostic prompts
   - Analyze pod status
   - Review events
   - Check logs

2. **Use kagent to Analyze Cluster State**
   - Run cluster health analysis
   - Check resource availability
   - Identify bottlenecks
   - Review recent changes

3. **Identify Root Cause**
   - Image pull errors (ImagePullBackOff)
   - Secret misconfigurations (missing env vars)
   - Resource limits (OOMKilled, CPU throttling)
   - Port mismatches (service not accessible)
   - Configuration errors (CrashLoopBackOff)

4. **Apply Fix**
   - Update configuration
   - Adjust resource limits
   - Fix secret references
   - Correct port mappings

5. **Validate Fix**
   - Redeploy with corrections
   - Monitor pod startup
   - Verify health checks
   - Test functionality

**No blind redeployments allowed** - Always diagnose before redeploying.

## Scalability Preparation

System MUST be designed for:

- **HPA-Ready**: Horizontal Pod Autoscaler configured
- **Cloud-Migration Ready**: Works on any Kubernetes cluster
- **Environment Variable Driven**: No hardcoded configuration
- **Namespace-Isolated**: Proper resource isolation
- **Stateless**: No local state in containers
- **Database Connection Pooling**: Efficient database access
- **Graceful Shutdown**: Handle SIGTERM properly
- **Zero-Downtime Deployments**: Rolling updates configured

## Observability Standards

### Logging
- All logs MUST be structured JSON
- Logs MUST include:
  - timestamp (ISO 8601)
  - service name
  - severity level (debug, info, warn, error, fatal)
  - trace_id (for request tracing)
  - user_id (when applicable)
  - message
  - metadata (context-specific)

### Monitoring
- Prometheus metrics exposed
- Key metrics:
  - Request rate
  - Error rate
  - Response time (p50, p95, p99)
  - Pod CPU/memory usage
  - Cohere API latency
  - Token usage

### Alerting
- CrashLoopBackOff triggers alert
- OOMKilled triggers alert
- High error rate triggers alert
- Slow response time triggers alert

## Development Workflow

### Specification Phase
1. Feature requirements documented in `specs/<feature>/spec.md`
2. Acceptance criteria clearly defined
3. User stories and edge cases identified
4. AI tool requirements specified if applicable
5. Infrastructure requirements defined
6. Containerization strategy outlined
7. Spec reviewed and approved before proceeding

### Planning Phase
1. Architecture decisions documented in `specs/<feature>/plan.md`
2. API contracts defined
3. Database schema changes planned
4. MCP tool contracts defined (if AI feature)
5. Containerization plan created
6. Kubernetes resources designed
7. Helm chart structure planned
8. Security implications assessed
9. ADRs created for significant decisions

### Implementation Phase
1. Tasks broken down in `specs/<feature>/tasks.md`
2. Each task includes test cases
3. Implementation via Claude Code agents
4. PHRs created for all significant work
5. Code changes follow smallest viable diff principle
6. AI tools implemented with strict validation
7. Dockerfiles generated
8. Helm charts created
9. Kubernetes manifests generated

### Validation Phase
1. All acceptance criteria verified
2. Security checks passed (user isolation, JWT verification)
3. UI/UX standards met
4. AI tool validation (no hallucinations, correct user scoping)
5. Container images validated
6. Kubernetes deployment validated
7. Health checks passing
8. Cross-browser/device testing completed
9. Documentation updated

## Prohibitions

The following actions are STRICTLY PROHIBITED:

- No manual kubectl apply (use kubectl-ai or Helm)
- No hardcoded credentials in code or containers
- No skipping spec phase
- No direct container exec fixes without documentation
- No manual coding outside agentic workflow
- No privileged containers
- No root user in containers
- No secrets in Dockerfiles or code
- No blind redeployments without diagnosis
- No raw YAML apply without tool generation

## Success Criteria

### Phase IV is Complete When:

#### Core Application
- [ ] User can sign up and sign in securely
- [ ] Each user only sees and modifies their own tasks
- [ ] All CRUD operations work end-to-end
- [ ] UI is responsive, visually refined, and intuitive
- [ ] No hardcoded secrets or credentials
- [ ] JWT verification on all protected endpoints
- [ ] Database queries properly scoped to authenticated user

#### AI Chatbot
- [ ] Add tasks via natural language through AI chat
- [ ] List tasks (all/pending/completed) via AI chat
- [ ] Complete tasks by ID via AI chat
- [ ] Delete tasks by ID or title resolution via AI chat
- [ ] Update tasks via AI chat
- [ ] Conversation resumes correctly after server restart
- [ ] AI correctly identifies logged-in user
- [ ] AI operates entirely via MCP tools (no direct DB access)
- [ ] Cohere API integrated as reasoning engine
- [ ] System scales without session state
- [ ] No hallucinated task IDs or fabricated data
- [ ] All AI tool calls validated for user authorization

#### Containerization
- [ ] Frontend containerized with optimized Dockerfile
- [ ] Backend containerized with optimized Dockerfile
- [ ] Images build successfully via Gordon
- [ ] Images are < 200MB (frontend), < 150MB (backend)
- [ ] Multi-stage builds implemented
- [ ] No secrets in container images
- [ ] Images tagged with versions
- [ ] Containers run as non-root user

#### Kubernetes Deployment
- [ ] Frontend and backend running on Minikube
- [ ] Helm charts generated and validated
- [ ] All pods in Running state
- [ ] Services accessible (ClusterIP)
- [ ] Liveness probes passing
- [ ] Readiness probes passing
- [ ] Resource limits defined
- [ ] Replica count: frontend (2), backend (2+)
- [ ] Secrets managed via Kubernetes Secrets
- [ ] RBAC configured with least privilege

#### AI DevOps
- [ ] kubectl-ai functional for cluster operations
- [ ] kagent functional for diagnostics
- [ ] Gordon functional for Docker operations
- [ ] Cluster health analysis passing
- [ ] No CrashLoopBackOff or OOMKilled pods
- [ ] Scaling functional (HPA-ready)
- [ ] Zero-downtime deployments working

#### Documentation & Quality
- [ ] Entire system can be explained clearly from spec → plan → implementation
- [ ] All tests pass
- [ ] Documentation is complete and accurate
- [ ] Infrastructure documented
- [ ] Deployment procedures documented

## Governance

### Amendment Process
1. Proposed changes documented with rationale
2. Impact analysis on existing specs, plans, and code
3. Approval required before implementation
4. Version number incremented according to semantic versioning:
   - **MAJOR**: Backward incompatible principle changes (e.g., architectural model change)
   - **MINOR**: New principles or sections added
   - **PATCH**: Clarifications, wording improvements, typo fixes
5. Dependent templates and documentation updated
6. Migration plan created if existing code affected

### Compliance
- All PRs MUST verify compliance with constitution principles
- Spec reviews MUST check alignment with core principles
- Security reviews MUST verify user isolation and JWT verification
- UI reviews MUST verify adherence to design standards
- AI tool reviews MUST verify stateless operation and user scoping
- Infrastructure reviews MUST verify containerization and Kubernetes standards
- Complexity MUST be justified against simplicity principle

### Version Control
- Constitution changes tracked in git
- Each amendment creates a new version
- Sync Impact Report prepended to document
- PHR created for each amendment

### Runtime Guidance
For day-to-day development guidance, refer to `CLAUDE.md` which provides operational instructions for Claude Code agents working within this constitutional framework.

**Version**: 2.0.0 | **Ratified**: 2026-02-05 | **Last Amended**: 2026-02-16
