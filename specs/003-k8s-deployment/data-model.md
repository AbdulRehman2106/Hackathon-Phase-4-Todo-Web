# Data Model: Kubernetes Resources & Container Specifications

**Feature**: 003-k8s-deployment
**Date**: 2026-02-16
**Phase**: 1 (Design & Contracts)

## Purpose

This document defines all Kubernetes resources, container specifications, and infrastructure data models for Phase IV deployment. Unlike traditional data models focused on database entities, this model describes containerized infrastructure.

---

## Container Images

### Frontend Container Image

**Image Name**: `todo-frontend:latest`

**Base Image**: `node:20-alpine`

**Build Strategy**: Multi-stage build

**Stages**:
1. **Builder Stage** (`builder`)
   - Base: `node:20-alpine`
   - Purpose: Install dependencies, build Next.js application
   - Operations:
     - Copy package.json, package-lock.json
     - Run `npm ci` (clean install)
     - Copy source code
     - Run `npm run build`
   - Output: `.next/` build directory, node_modules/

2. **Runtime Stage** (`runner`)
   - Base: `node:20-alpine`
   - Purpose: Minimal runtime environment
   - Operations:
     - Copy only production dependencies
     - Copy `.next/` from builder
     - Copy public/ assets
     - Set non-root user
   - Exposed Port: 3000
   - Entrypoint: `npm start`

**Size Target**: < 200MB

**Security**:
- Runs as non-root user (node:node, UID 1000)
- No shell access in production
- Minimal attack surface (Alpine base)

**Environment Variables**:
- `NEXT_PUBLIC_API_URL`: Backend API endpoint
- `NODE_ENV`: production

**Health Endpoints**:
- `/health`: Liveness check (returns 200 if server running)
- `/ready`: Readiness check (returns 200 if backend reachable)

---

### Backend Container Image

**Image Name**: `todo-backend:latest`

**Base Image**: `python:3.11-slim`

**Build Strategy**: Multi-stage build

**Stages**:
1. **Builder Stage** (`builder`)
   - Base: `python:3.11-slim`
   - Purpose: Install dependencies with build tools
   - Operations:
     - Install build dependencies (gcc, etc.)
     - Copy requirements.txt
     - Run `pip install --user` (installs to ~/.local)
   - Output: Python packages in /root/.local

2. **Runtime Stage** (`runner`)
   - Base: `python:3.11-slim`
   - Purpose: Minimal runtime environment
   - Operations:
     - Copy Python packages from builder
     - Copy application source code
     - Set non-root user
   - Exposed Port: 8000
   - Entrypoint: `uvicorn src.main:app --host 0.0.0.0 --port 8000`

**Size Target**: < 150MB

**Security**:
- Runs as non-root user (appuser, UID 1000)
- No build tools in runtime image
- Minimal dependencies

**Environment Variables**:
- `DATABASE_URL`: PostgreSQL connection string (from Secret)
- `COHERE_API_KEY`: Cohere API key (from Secret)
- `JWT_SECRET`: JWT signing key (from Secret)
- `ENVIRONMENT`: production

**Health Endpoints**:
- `/health`: Liveness check (returns 200 if FastAPI running)
- `/ready`: Readiness check (returns 200 if database connection healthy)

---

## Kubernetes Resources

### Deployment Resource

**Purpose**: Manages pod replicas, rolling updates, and desired state

**Frontend Deployment Specification**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-frontend
  labels:
    app: todo-frontend
    component: frontend
    tier: presentation
spec:
  replicas: 2  # Configurable via values.yaml
  selector:
    matchLabels:
      app: todo-frontend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Zero downtime
  template:
    metadata:
      labels:
        app: todo-frontend
        component: frontend
    spec:
      containers:
      - name: frontend
        image: todo-frontend:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NEXT_PUBLIC_API_URL
          valueFrom:
            configMapKeyRef:
              name: frontend-config
              key: api_url
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
```

**Backend Deployment Specification**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-backend
  labels:
    app: todo-backend
    component: backend
    tier: application
spec:
  replicas: 2  # Configurable via values.yaml
  selector:
    matchLabels:
      app: todo-backend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Zero downtime
  template:
    metadata:
      labels:
        app: todo-backend
        component: backend
    spec:
      containers:
      - name: backend
        image: todo-backend:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: database_url
        - name: COHERE_API_KEY
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: cohere_api_key
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: jwt_secret
        - name: ENVIRONMENT
          value: "production"
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
```

---

### Service Resource

**Purpose**: Provides stable network endpoint for pod access

**Frontend Service**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: todo-frontend
  labels:
    app: todo-frontend
spec:
  type: ClusterIP
  ports:
  - port: 3000
    targetPort: 3000
    protocol: TCP
    name: http
  selector:
    app: todo-frontend
```

**Backend Service**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: todo-backend
  labels:
    app: todo-backend
spec:
  type: ClusterIP
  ports:
  - port: 8000
    targetPort: 8000
    protocol: TCP
    name: http
  selector:
    app: todo-backend
```

**Service Discovery**:
- Frontend accesses backend via: `http://todo-backend:8000`
- DNS resolution handled by Kubernetes CoreDNS
- ClusterIP provides stable internal IP

---

### ConfigMap Resource

**Purpose**: Store non-sensitive configuration data

**Frontend ConfigMap**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  api_url: "http://todo-backend:8000"
  log_level: "info"
  environment: "production"
```

**Backend ConfigMap**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  log_level: "info"
  environment: "production"
  cors_origins: "http://todo-frontend:3000"
```

---

### Secret Resource

**Purpose**: Store sensitive data (API keys, credentials)

**Backend Secrets**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: backend-secrets
type: Opaque
data:
  # All values base64-encoded
  database_url: <base64-encoded-postgresql-url>
  cohere_api_key: <base64-encoded-cohere-key>
  jwt_secret: <base64-encoded-jwt-secret>
```

**Creation Method**:
```bash
kubectl create secret generic backend-secrets \
  --from-literal=database_url="postgresql://user:pass@host/db" \
  --from-literal=cohere_api_key="your-cohere-key" \
  --from-literal=jwt_secret="your-jwt-secret"
```

**Security**:
- Never committed to Git
- Encrypted at rest (if etcd encryption enabled)
- RBAC restricts access
- Mounted as environment variables (not files)

---

### HorizontalPodAutoscaler Resource

**Purpose**: Automatically scale replicas based on CPU utilization

**Frontend HPA**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: todo-frontend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: todo-frontend
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # 5 minutes
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
```

**Backend HPA**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: todo-backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: todo-backend
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # 5 minutes
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
```

**Scaling Behavior**:
- Scale up: Immediate (0s stabilization)
- Scale down: 5 minute stabilization (prevent flapping)
- Scale up rate: 100% per 30s (double replicas quickly)
- Scale down rate: 50% per 60s (gradual reduction)

---

### Ingress Resource (Optional)

**Purpose**: External HTTP/HTTPS access to services

**Ingress Specification**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: todo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: todo-frontend
            port:
              number: 3000
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: todo-backend
            port:
              number: 8000
```

**Access**:
- Add to `/etc/hosts`: `127.0.0.1 todo.local`
- Access via: `http://todo.local`
- API via: `http://todo.local/api`

---

## Resource Relationships

```
┌─────────────────────────────────────────────────────────┐
│                    Ingress (Optional)                    │
│                     todo.local                           │
└────────────────┬────────────────────┬───────────────────┘
                 │                    │
                 │ / (frontend)       │ /api (backend)
                 │                    │
        ┌────────▼────────┐  ┌────────▼────────┐
        │  Frontend Svc   │  │  Backend Svc    │
        │  ClusterIP      │  │  ClusterIP      │
        │  Port: 3000     │  │  Port: 8000     │
        └────────┬────────┘  └────────┬────────┘
                 │                    │
                 │                    │
        ┌────────▼────────┐  ┌────────▼────────┐
        │ Frontend Deploy │  │ Backend Deploy  │
        │  Replicas: 2-5  │  │  Replicas: 2-5  │
        └────────┬────────┘  └────────┬────────┘
                 │                    │
         ┌───────┴───────┐    ┌───────┴───────┐
         │               │    │               │
    ┌────▼────┐    ┌────▼────▼────┐    ┌────▼────┐
    │ Pod 1   │    │ Pod 2   │ Pod 1   │    │ Pod 2   │
    │ (FE)    │    │ (FE)    │ (BE)    │    │ (BE)    │
    └─────────┘    └─────────┴─────────┘    └─────────┘
         │                         │
         │                         │
    ┌────▼─────────────────────────▼────┐
    │      Frontend ConfigMap           │
    └───────────────────────────────────┘
                              │
                         ┌────▼────────────────┐
                         │  Backend Secrets    │
                         │  (API keys, DB URL) │
                         └─────────────────────┘
                                   │
                         ┌─────────▼──────────┐
                         │  External Services │
                         │  - Neon PostgreSQL │
                         │  - Cohere API      │
                         └────────────────────┘
```

---

## Resource Sizing Summary

| Resource | Min Replicas | Max Replicas | CPU Request | CPU Limit | Memory Request | Memory Limit |
|----------|--------------|--------------|-------------|-----------|----------------|--------------|
| Frontend | 2 | 5 | 100m | 500m | 256Mi | 512Mi |
| Backend | 2 | 5 | 250m | 1000m | 512Mi | 1Gi |

**Total Cluster Requirements**:
- Minimum: 700m CPU, 1.5Gi memory (2 replicas each)
- Maximum: 3.5 CPU, 7.5Gi memory (5 replicas each)
- Recommended Minikube: 4 CPU, 8Gi memory

---

## Validation Checklist

- [ ] Container images build successfully
- [ ] Images under size limits (frontend <200MB, backend <150MB)
- [ ] Images run as non-root
- [ ] Health endpoints return 200
- [ ] Deployments create pods successfully
- [ ] Services route traffic correctly
- [ ] ConfigMaps mounted as environment variables
- [ ] Secrets mounted securely
- [ ] HPA scales based on CPU
- [ ] Rolling updates complete without downtime
- [ ] Ingress routes traffic correctly (if enabled)

---

**Data Model Status**: ✅ Complete
**Resources Defined**: 8 types (Image, Deployment, Service, ConfigMap, Secret, HPA, Ingress)
**Ready for**: Contract generation (Helm values schemas)
