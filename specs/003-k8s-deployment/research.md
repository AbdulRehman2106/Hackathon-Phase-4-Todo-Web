# Research: Kubernetes Deployment Technologies

**Feature**: 003-k8s-deployment
**Date**: 2026-02-16
**Phase**: 0 (Research & Technology Decisions)

## Purpose

This document captures all technology research, decisions, and rationale for Phase IV Kubernetes deployment. All "NEEDS CLARIFICATION" items from the Technical Context have been resolved through this research.

## Research Questions Resolved

### 1. Container Base Image Selection

**Question**: Which base images provide optimal size/security/compatibility balance?

**Research Findings**:
- Alpine Linux: 5MB base, minimal attack surface, apk package manager
- Debian Slim: 50MB base, apt package manager, better compatibility
- Distroless: No shell, maximum security, harder debugging
- Standard images: 100MB+, unnecessary bloat

**Decision**:
- **Frontend**: `node:20-alpine` (Alpine-based)
- **Backend**: `python:3.11-slim` (Debian slim)

**Rationale**:
- Alpine works well for Node.js (native binaries available)
- Python on Alpine has wheel compatibility issues (many packages need compilation)
- Slim provides good balance for Python (pre-built wheels available)
- Both meet size constraints (<200MB frontend, <150MB backend)

**Alternatives Rejected**:
- Distroless: Too complex for local development, debugging difficult
- Standard images: Exceed size constraints, unnecessary packages

---

### 2. Kubernetes Package Management

**Question**: How should we manage Kubernetes manifests and deployments?

**Research Findings**:
- Raw YAML: Simple but no templating, hard to maintain
- Kustomize: Built-in to kubectl, overlay-based
- Helm: Template engine, package manager, versioning
- Operators: Custom controllers, complex

**Decision**: **Helm 3.x with separate charts per service**

**Rationale**:
- Industry standard for Kubernetes packaging
- Powerful templating (values.yaml for configuration)
- Version management and rollback support
- Separate charts enable independent service deployment
- No Tiller (Helm 3 is client-only, more secure)

**Alternatives Rejected**:
- Raw YAML: No templating, duplication across environments
- Kustomize: Less flexible than Helm for complex scenarios
- Operators: Overkill for 2 services, adds complexity

---

### 3. Secrets Management Strategy

**Question**: How should we securely manage API keys and credentials in Kubernetes?

**Research Findings**:
- Kubernetes Secrets: Native, base64-encoded, encrypted at rest (if configured)
- Sealed Secrets: GitOps-friendly, requires controller
- External Secrets Operator: Syncs from external stores (Vault, AWS Secrets Manager)
- HashiCorp Vault: Enterprise-grade, complex setup

**Decision**: **Kubernetes native Secrets**

**Rationale**:
- Built-in, no additional dependencies
- Sufficient for local development (Minikube)
- Simple workflow: `kubectl create secret`
- Mounted as environment variables or files
- Encrypted at rest if etcd encryption enabled

**Alternatives Rejected**:
- Sealed Secrets: Adds complexity, requires controller installation
- External Secrets Operator: Requires external secret store
- Vault: Overkill for local deployment, complex setup

**Security Measures**:
- Never commit secrets to Git
- Provide `.yaml.example` templates
- Document secret creation in quickstart.md
- Use RBAC to restrict secret access

---

### 4. Service Communication Pattern

**Question**: Should we use a service mesh for inter-service communication?

**Research Findings**:
- No mesh: Direct ClusterIP services, simple
- Istio: Full-featured, heavy (1GB+ overhead), complex
- Linkerd: Lightweight, still adds overhead
- Consul Connect: HashiCorp ecosystem, requires Consul

**Decision**: **No service mesh (direct ClusterIP services)**

**Rationale**:
- Only 2 services (frontend → backend)
- Local development environment
- Service mesh overhead not justified
- Simple ClusterIP services sufficient
- Can add mesh later if needed (not breaking change)

**Alternatives Rejected**:
- Istio: Too heavy for local Minikube (resource constraints)
- Linkerd: Still adds complexity for minimal benefit
- Consul: Requires additional infrastructure

**Implementation**:
- Frontend Service: ClusterIP, port 3000
- Backend Service: ClusterIP, port 8000
- Frontend connects to backend via service DNS: `http://backend:8000`

---

### 5. Ingress Controller Selection

**Question**: How should external traffic reach the cluster?

**Research Findings**:
- Minikube ingress addon: NGINX-based, built-in
- Traefik: Modern, dynamic configuration
- Kong: API gateway features, complex
- HAProxy: High performance, less Kubernetes-native

**Decision**: **Minikube ingress addon (NGINX)**

**Rationale**:
- Pre-installed with Minikube
- Simple enable: `minikube addons enable ingress`
- Standard NGINX Ingress Controller
- Sufficient for local development
- Well-documented, widely used

**Alternatives Rejected**:
- Traefik: Requires separate installation
- Kong: Overkill for local dev, complex configuration
- HAProxy: Less Kubernetes-native

**Implementation**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todo-ingress
spec:
  rules:
  - host: todo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 3000
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 8000
```

---

### 6. Container Registry Strategy

**Question**: Where should container images be stored and accessed?

**Research Findings**:
- Docker Desktop: Local, no push needed, Minikube can access directly
- Minikube registry addon: Requires image push, extra step
- Docker Hub: Public/private, requires authentication, slower
- Local registry: Requires setup, port forwarding

**Decision**: **Docker Desktop local images**

**Rationale**:
- Minikube can use Docker Desktop's image cache directly
- No push step required (faster iteration)
- No authentication needed
- No external dependencies
- Perfect for local development

**Configuration**:
```bash
# Use Docker Desktop as Minikube driver
minikube start --driver=docker

# Images built with docker build are immediately available
docker build -t todo-frontend:latest ./frontend
# Minikube can now use todo-frontend:latest directly
```

**Alternatives Rejected**:
- Minikube registry: Extra push step, slower workflow
- Docker Hub: Requires auth, slower, unnecessary for local
- Local registry: Additional setup complexity

---

### 7. Health Check Implementation

**Question**: What health check strategy ensures reliable pod management?

**Research Findings**:
- Liveness probe: Detects if container is alive (restart if fails)
- Readiness probe: Detects if container can serve traffic (remove from service if fails)
- Startup probe: Gives slow-starting containers time to initialize
- Probe types: HTTP, TCP, Exec

**Decision**: **HTTP probes on dedicated endpoints**

**Rationale**:
- HTTP provides most information (status code, response body)
- Separate endpoints for liveness vs readiness
- Standard pattern across industry
- Easy to implement and test

**Implementation**:

**Liveness Probe** (`/health`):
- Checks: Application process is running
- Failure action: Restart container
- Frontend: Returns 200 if Next.js server responding
- Backend: Returns 200 if FastAPI server responding

**Readiness Probe** (`/ready`):
- Checks: Application + dependencies ready
- Failure action: Remove from service endpoints
- Frontend: Returns 200 if backend reachable
- Backend: Returns 200 if database connection pool healthy

**Configuration**:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 2
```

**Alternatives Rejected**:
- TCP probes: Less informative, can't check dependencies
- Exec probes: Requires shell in container, slower

---

### 8. Resource Management Strategy

**Question**: How should CPU and memory be allocated to pods?

**Research Findings**:
- Requests only: No guarantee, can be evicted
- Limits only: No resource reservation, can be throttled
- Both: Guaranteed QoS, predictable performance
- QoS classes: Guaranteed (requests=limits), Burstable (requests<limits), BestEffort (none)

**Decision**: **Set both requests and limits (Guaranteed QoS)**

**Rationale**:
- Guaranteed QoS ensures pods get resources they need
- Prevents resource starvation
- Predictable performance
- Kubernetes won't evict unless node fails

**Resource Allocation**:

**Frontend**:
- CPU request: 100m (0.1 core)
- CPU limit: 500m (0.5 core)
- Memory request: 256Mi
- Memory limit: 512Mi
- Rationale: Next.js SSR needs moderate CPU, low memory

**Backend**:
- CPU request: 250m (0.25 core)
- CPU limit: 1000m (1 core)
- Memory request: 512Mi
- Memory limit: 1Gi
- Rationale: FastAPI + AI processing needs more resources

**Alternatives Rejected**:
- Requests only: Unpredictable performance, can be evicted
- Limits only: No resource guarantee, can be starved
- Burstable QoS: Less predictable than Guaranteed

---

### 9. Autoscaling Configuration

**Question**: How should pods scale based on load?

**Research Findings**:
- HPA (Horizontal Pod Autoscaler): Scales replicas based on metrics
- VPA (Vertical Pod Autoscaler): Adjusts resource requests/limits
- Metrics: CPU, memory, custom (requires metrics server)
- Scaling algorithms: Target utilization, target value

**Decision**: **CPU-based HPA with 80% target utilization**

**Rationale**:
- CPU is good proxy for web application load
- 80% target leaves headroom for spikes
- Simple, no custom metrics needed
- Metrics server included in Minikube

**Configuration**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

**Scaling Behavior**:
- Min replicas: 2 (high availability)
- Max replicas: 5 (Minikube resource limit)
- Scale up: When CPU > 80% for 30s
- Scale down: When CPU < 80% for 5 minutes (slower to prevent flapping)

**Alternatives Rejected**:
- Memory-based: Less predictable for web apps
- Custom metrics: Requires additional setup
- VPA: Changes pod resources, not replica count

---

### 10. Logging Architecture

**Question**: How should application logs be collected and structured?

**Research Findings**:
- stdout/stderr: Kubernetes captures automatically
- File-based: Requires volume mounts, log rotation
- Sidecar: Separate container for log processing
- Structured logging: JSON format for parsing

**Decision**: **Structured JSON logs to stdout**

**Rationale**:
- Kubernetes captures stdout automatically
- JSON enables parsing and filtering
- No volume mounts needed
- Standard pattern for cloud-native apps
- Compatible with log aggregation tools (ELK, Loki)

**Implementation**:

**Frontend (Winston)**:
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console()
  ]
});
```

**Backend (structlog)**:
```python
import structlog

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ]
)

logger = structlog.get_logger()
```

**Log Format**:
```json
{
  "timestamp": "2026-02-16T10:30:00.000Z",
  "level": "info",
  "message": "Request processed",
  "user_id": "user_123",
  "request_id": "req_456",
  "duration_ms": 150
}
```

**Alternatives Rejected**:
- File-based: Requires volume mounts, log rotation complexity
- Sidecar: Adds container overhead, unnecessary
- Plain text: Harder to parse and filter

---

## Technology Stack Summary

| Component | Technology | Version | Decision Rationale |
|-----------|-----------|---------|-------------------|
| Container Runtime | Docker Desktop | Latest | Gordon AI integration, local development |
| Orchestration | Minikube | 1.32+ | Local K8s, easy setup, sufficient resources |
| Package Manager | Helm | 3.x | Industry standard, templating, versioning |
| AI Operations | kubectl-ai | Latest | Intelligent K8s operations, error diagnosis |
| Diagnostics | kagent | Latest | Cluster health analysis, performance insights |
| Docker AI | Gordon | Built-in | Dockerfile optimization, best practices |
| Frontend Base | node:20-alpine | 20-alpine | Minimal size (5MB base), Node.js compatibility |
| Backend Base | python:3.11-slim | 3.11-slim | Python wheel compatibility, reasonable size |
| Ingress | NGINX (Minikube) | Latest | Built-in, simple, standard |
| Secrets | K8s Secrets | Native | No dependencies, sufficient for local |
| Service Mesh | None | N/A | Unnecessary for 2 services |
| Registry | Docker Desktop | Local | No push needed, fast iteration |
| Logging | JSON to stdout | N/A | K8s native, parseable, standard |

## Implementation Readiness

All research questions have been resolved. No blockers identified. Ready to proceed to Phase 1 (Design & Contracts).

**Next Steps**:
1. Create data-model.md (Kubernetes resource specifications)
2. Create contracts/ (Helm values schemas)
3. Create quickstart.md (Deployment guide)
4. Update agent context with new technologies

---

**Research Status**: ✅ Complete
**Blockers**: None
**Ready for**: Phase 1 (Design & Contracts)
