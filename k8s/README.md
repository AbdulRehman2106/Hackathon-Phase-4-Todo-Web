# Kubernetes Deployment Guide

## Phase 4: Cloud-Native Kubernetes Deployment

This guide covers deploying the Todo Application to Kubernetes using the manifests in this directory.

## Prerequisites

- Docker installed and running
- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)
- kubectl CLI installed and configured
- Docker images built:
  - `phase4-backend:latest`
  - `phase4-frontend:latest`

## Directory Structure

```
k8s/
├── base/
│   ├── namespace.yaml              # Namespace definition
│   ├── configmap.yaml              # Application configuration
│   ├── secrets.yaml.example        # Secrets template (DO NOT commit real secrets)
│   ├── backend-deployment.yaml     # Backend deployment
│   ├── backend-service.yaml        # Backend service (ClusterIP)
│   ├── frontend-deployment.yaml    # Frontend deployment
│   ├── frontend-service.yaml       # Frontend service (LoadBalancer)
│   └── kustomization.yaml          # Kustomize configuration
└── overlays/
    ├── dev/                        # Development environment overrides
    └── prod/                       # Production environment overrides
```

## Deployment Steps

### 1. Prepare Secrets

Copy the secrets example and fill in your actual values:

```bash
cp k8s/base/secrets.yaml.example k8s/base/secrets.yaml
```

Edit `k8s/base/secrets.yaml` and replace placeholder values:
- `DATABASE_URL`: Your PostgreSQL connection string
- `JWT_SECRET_KEY`: Generate with `openssl rand -hex 32`
- `COHERE_API_KEY`: Your Cohere API key (optional)

**IMPORTANT:** Add `k8s/base/secrets.yaml` to `.gitignore` to prevent committing secrets!

### 2. Load Docker Images (for Minikube)

If using Minikube, load the Docker images into the cluster:

```bash
minikube image load phase4-backend:latest
minikube image load phase4-frontend:latest
```

For Docker Desktop Kubernetes, images are already available.

### 3. Deploy to Kubernetes

Apply all manifests using kubectl:

```bash
# Create namespace
kubectl apply -f k8s/base/namespace.yaml

# Apply secrets (ensure you've created this from the example)
kubectl apply -f k8s/base/secrets.yaml

# Apply all other resources
kubectl apply -f k8s/base/
```

Or use Kustomize:

```bash
kubectl apply -k k8s/base/
```

### 4. Verify Deployment

Check the status of all resources:

```bash
# Check namespace
kubectl get namespace todo-app

# Check all resources in the namespace
kubectl get all -n todo-app

# Check pods status
kubectl get pods -n todo-app

# Check services
kubectl get services -n todo-app

# Check deployments
kubectl get deployments -n todo-app
```

### 5. Access the Application

#### Get Frontend Service URL

For Minikube:
```bash
minikube service frontend-service -n todo-app --url
```

For Docker Desktop:
```bash
kubectl get service frontend-service -n todo-app
# Access via http://localhost:3000
```

For cloud providers, get the LoadBalancer external IP:
```bash
kubectl get service frontend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Monitoring and Debugging

### View Logs

```bash
# Backend logs
kubectl logs -n todo-app -l component=backend --tail=100 -f

# Frontend logs
kubectl logs -n todo-app -l component=frontend --tail=100 -f
```

### Check Pod Health

```bash
# Describe backend pods
kubectl describe pods -n todo-app -l component=backend

# Describe frontend pods
kubectl describe pods -n todo-app -l component=frontend
```

### Execute Commands in Pods

```bash
# Shell into backend pod
kubectl exec -it -n todo-app deployment/backend -- /bin/bash

# Shell into frontend pod
kubectl exec -it -n todo-app deployment/frontend -- /bin/sh
```

## Scaling

### Manual Scaling

```bash
# Scale backend
kubectl scale deployment backend -n todo-app --replicas=3

# Scale frontend
kubectl scale deployment frontend -n todo-app --replicas=3
```

### Auto-scaling (HPA)

Create a Horizontal Pod Autoscaler:

```bash
# Backend autoscaling
kubectl autoscale deployment backend -n todo-app \
  --cpu-percent=70 \
  --min=2 \
  --max=10

# Frontend autoscaling
kubectl autoscale deployment frontend -n todo-app \
  --cpu-percent=70 \
  --min=2 \
  --max=10
```

## Configuration Updates

### Update ConfigMap

Edit `k8s/base/configmap.yaml` and reapply:

```bash
kubectl apply -f k8s/base/configmap.yaml

# Restart deployments to pick up changes
kubectl rollout restart deployment backend -n todo-app
kubectl rollout restart deployment frontend -n todo-app
```

### Update Secrets

Edit `k8s/base/secrets.yaml` and reapply:

```bash
kubectl apply -f k8s/base/secrets.yaml

# Restart deployments to pick up changes
kubectl rollout restart deployment backend -n todo-app
kubectl rollout restart deployment frontend -n todo-app
```

## Rolling Updates

### Update Docker Images

After building new images:

```bash
# Load new images (Minikube)
minikube image load phase4-backend:v1.0.1
minikube image load phase4-frontend:v1.0.1

# Update deployment image
kubectl set image deployment/backend backend=phase4-backend:v1.0.1 -n todo-app
kubectl set image deployment/frontend frontend=phase4-frontend:v1.0.1 -n todo-app

# Check rollout status
kubectl rollout status deployment/backend -n todo-app
kubectl rollout status deployment/frontend -n todo-app
```

### Rollback

If something goes wrong:

```bash
# Rollback backend
kubectl rollout undo deployment/backend -n todo-app

# Rollback frontend
kubectl rollout undo deployment/frontend -n todo-app
```

## Health Checks

The deployments include health checks:

- **Liveness Probe**: Checks if the container is alive (restarts if failing)
- **Readiness Probe**: Checks if the container is ready to serve traffic

### Backend Health Endpoints
- Liveness: `GET /health`
- Readiness: `GET /health`

### Frontend Health Endpoints
- Liveness: `GET /health`
- Readiness: `GET /ready`

## Resource Management

Current resource allocations:

**Backend:**
- Requests: 256Mi memory, 250m CPU
- Limits: 512Mi memory, 500m CPU

**Frontend:**
- Requests: 256Mi memory, 250m CPU
- Limits: 512Mi memory, 500m CPU

Adjust these in the deployment YAML files based on your needs.

## Security

### Security Features Implemented

1. **Non-root users**: Containers run as non-root users (UID 1000/1001)
2. **Read-only root filesystem**: Where possible
3. **No privilege escalation**: `allowPrivilegeEscalation: false`
4. **Secrets management**: Sensitive data stored in Kubernetes Secrets
5. **Network policies**: Can be added for additional isolation

### Recommended Additional Security

```bash
# Create network policies
kubectl apply -f k8s/base/network-policies.yaml

# Enable Pod Security Standards
kubectl label namespace todo-app pod-security.kubernetes.io/enforce=restricted
```

## Cleanup

To remove all resources:

```bash
# Delete all resources in namespace
kubectl delete namespace todo-app

# Or delete individual resources
kubectl delete -k k8s/base/
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n todo-app

# Check logs
kubectl logs <pod-name> -n todo-app
```

### Image Pull Errors

For Minikube, ensure images are loaded:
```bash
minikube image ls | grep phase4
```

### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n todo-app

# Check if pods are ready
kubectl get pods -n todo-app
```

### Database Connection Issues

Verify the DATABASE_URL secret is correct:
```bash
kubectl get secret todo-app-secrets -n todo-app -o jsonpath='{.data.DATABASE_URL}' | base64 -d
```

## Next Steps

1. Set up Ingress for external access
2. Configure persistent storage for database
3. Implement monitoring with Prometheus/Grafana
4. Set up CI/CD pipeline for automated deployments
5. Configure backup and disaster recovery

## Support

For issues or questions, refer to:
- Kubernetes documentation: https://kubernetes.io/docs/
- Project repository: [Your repo URL]
