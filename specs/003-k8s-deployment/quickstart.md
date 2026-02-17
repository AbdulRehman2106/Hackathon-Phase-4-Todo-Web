# Quick Start: Kubernetes Deployment

**Feature**: 003-k8s-deployment
**Purpose**: Step-by-step guide to deploy Todo Chatbot to local Kubernetes (Minikube)
**Time**: ~30 minutes for first-time setup

## Prerequisites

### Required Software

| Tool | Version | Installation |
|------|---------|--------------|
| Docker Desktop | Latest | https://www.docker.com/products/docker-desktop |
| Minikube | 1.32+ | https://minikube.sigs.k8s.io/docs/start/ |
| Helm | 3.x | https://helm.sh/docs/intro/install/ |
| kubectl | 1.28+ | https://kubernetes.io/docs/tasks/tools/ |
| kubectl-ai | Latest | `kubectl krew install ai` |
| kagent | Latest | Installation instructions below |

### System Requirements

- **CPU**: 4 cores minimum (8 recommended)
- **Memory**: 8GB minimum (16GB recommended)
- **Disk**: 20GB free space
- **OS**: Windows 10+, macOS 11+, or Linux

### Required Credentials

- **Neon PostgreSQL**: Database connection string
- **Cohere API**: API key from https://dashboard.cohere.com/api-keys
- **JWT Secret**: Generate with `openssl rand -base64 32`

---

## Step 1: Install Prerequisites

### Install Docker Desktop

**Windows/macOS**:
1. Download from https://www.docker.com/products/docker-desktop
2. Run installer
3. Start Docker Desktop
4. Verify: `docker --version`

**Linux**:
```bash
# Install Docker Engine
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Enable Gordon (Docker AI)

Gordon is built into Docker Desktop:
```bash
# Verify Gordon is available
docker help | grep gordon

# If not available, update Docker Desktop to latest version
```

### Install Minikube

**Windows (PowerShell)**:
```powershell
choco install minikube
# Or download from https://minikube.sigs.k8s.io/docs/start/
```

**macOS**:
```bash
brew install minikube
```

**Linux**:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Verify:
```bash
minikube version
```

### Install Helm

**Windows (PowerShell)**:
```powershell
choco install kubernetes-helm
```

**macOS**:
```bash
brew install helm
```

**Linux**:
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify:
```bash
helm version
```

### Install kubectl

**Windows (PowerShell)**:
```powershell
choco install kubernetes-cli
```

**macOS**:
```bash
brew install kubectl
```

**Linux**:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Verify:
```bash
kubectl version --client
```

### Install kubectl-ai

```bash
# Install krew (kubectl plugin manager)
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Add krew to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Install kubectl-ai
kubectl krew install ai
```

Verify:
```bash
kubectl ai --version
```

### Install kagent

```bash
# Installation method depends on kagent distribution
# Check https://github.com/kagent-ai/kagent for latest instructions
```

---

## Step 2: Start Minikube Cluster

### Start Cluster

```bash
# Start Minikube with Docker driver
minikube start \
  --driver=docker \
  --cpus=4 \
  --memory=8192 \
  --disk-size=20g \
  --kubernetes-version=v1.28.0

# Wait for cluster to be ready (1-2 minutes)
```

### Verify Cluster

```bash
# Check cluster status
minikube status

# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system
```

Expected output:
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.28.0
```

### Enable Addons

```bash
# Enable metrics server (required for HPA)
minikube addons enable metrics-server

# Enable ingress (optional, for external access)
minikube addons enable ingress

# Verify addons
minikube addons list
```

### Configure kubectl Context

```bash
# Set context to minikube
kubectl config use-context minikube

# Verify context
kubectl config current-context
```

---

## Step 3: Build Container Images

### Navigate to Project Root

```bash
cd /path/to/Phase_4
```

### Build Frontend Image

```bash
# Build with Docker
docker build -t todo-frontend:latest ./frontend

# Verify image
docker images | grep todo-frontend

# Check image size (should be < 200MB)
docker images todo-frontend:latest --format "{{.Size}}"
```

**Optional: Use Gordon for optimization**:
```bash
docker gordon optimize todo-frontend:latest
```

### Build Backend Image

```bash
# Build with Docker
docker build -t todo-backend:latest ./backend

# Verify image
docker images | grep todo-backend

# Check image size (should be < 150MB)
docker images todo-backend:latest --format "{{.Size}}"
```

**Optional: Use Gordon for optimization**:
```bash
docker gordon optimize todo-backend:latest
```

### Test Images Locally (Optional)

```bash
# Test frontend
docker run -p 3000:3000 --rm todo-frontend:latest

# Test backend (requires environment variables)
docker run -p 8000:8000 --rm \
  -e DATABASE_URL="postgresql://..." \
  -e COHERE_API_KEY="..." \
  -e JWT_SECRET="..." \
  todo-backend:latest
```

---

## Step 4: Create Kubernetes Secrets

### Prepare Secret Values

```bash
# Set environment variables (replace with your actual values)
export DATABASE_URL="postgresql://user:password@ep-name.region.aws.neon.tech/neondb?sslmode=require"
export COHERE_API_KEY="your-cohere-api-key-here"
export JWT_SECRET=$(openssl rand -base64 32)

# Verify values are set
echo "Database URL: ${DATABASE_URL:0:20}..."
echo "Cohere API Key: ${COHERE_API_KEY:0:10}..."
echo "JWT Secret: ${JWT_SECRET:0:10}..."
```

### Create Secret

```bash
# Create backend secrets
kubectl create secret generic backend-secrets \
  --from-literal=database_url="$DATABASE_URL" \
  --from-literal=cohere_api_key="$COHERE_API_KEY" \
  --from-literal=jwt_secret="$JWT_SECRET"

# Verify secret created
kubectl get secret backend-secrets

# Check secret has correct keys
kubectl describe secret backend-secrets
```

Expected output:
```
Name:         backend-secrets
Type:         Opaque
Data
====
cohere_api_key:  40 bytes
database_url:    120 bytes
jwt_secret:      44 bytes
```

---

## Step 5: Deploy with Helm

### Deploy Backend

```bash
# Install backend chart
helm install todo-backend ./helm/backend \
  --set image.repository=todo-backend \
  --set image.tag=latest \
  --set secrets.secretName=backend-secrets

# Wait for deployment (1-2 minutes)
kubectl wait --for=condition=available --timeout=120s deployment/todo-backend

# Check deployment status
kubectl get deployment todo-backend
kubectl get pods -l app=todo-backend
```

### Deploy Frontend

```bash
# Install frontend chart
helm install todo-frontend ./helm/frontend \
  --set image.repository=todo-frontend \
  --set image.tag=latest \
  --set config.apiUrl="http://todo-backend:8000"

# Wait for deployment (1-2 minutes)
kubectl wait --for=condition=available --timeout=120s deployment/todo-frontend

# Check deployment status
kubectl get deployment todo-frontend
kubectl get pods -l app=todo-frontend
```

### Verify All Resources

```bash
# Check all deployments
kubectl get deployments

# Check all pods
kubectl get pods

# Check all services
kubectl get services

# Check HPA
kubectl get hpa
```

Expected output:
```
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
todo-backend    2/2     2            2           2m
todo-frontend   2/2     2            2           1m
```

---

## Step 6: Verify Deployment

### Check Pod Health

```bash
# Using kubectl-ai
kubectl ai "check health of all todo pods"

# Or manually
kubectl get pods -l app=todo-backend -o wide
kubectl get pods -l app=todo-frontend -o wide

# Check pod logs
kubectl logs -l app=todo-backend --tail=50
kubectl logs -l app=todo-frontend --tail=50
```

### Test Health Endpoints

```bash
# Port-forward backend
kubectl port-forward service/todo-backend 8000:8000 &

# Test backend health
curl http://localhost:8000/health
curl http://localhost:8000/ready

# Port-forward frontend
kubectl port-forward service/todo-frontend 3000:3000 &

# Test frontend health
curl http://localhost:3000/health
curl http://localhost:3000/ready

# Kill port-forwards
pkill -f "port-forward"
```

### Run Diagnostics with kagent

```bash
# Analyze cluster health
kagent analyze

# Check resource utilization
kagent resources

# Identify issues
kagent diagnose
```

---

## Step 7: Access Application

### Method 1: Port Forwarding (Simple)

```bash
# Forward frontend port
kubectl port-forward service/todo-frontend 3000:3000

# Access in browser: http://localhost:3000
```

### Method 2: Minikube Service (Recommended)

```bash
# Open frontend in browser
minikube service todo-frontend

# This automatically opens browser with correct URL
```

### Method 3: Ingress (Advanced)

If ingress addon is enabled:

```bash
# Get ingress IP
minikube ip

# Add to /etc/hosts (or C:\Windows\System32\drivers\etc\hosts on Windows)
echo "$(minikube ip) todo.local" | sudo tee -a /etc/hosts

# Access: http://todo.local
```

---

## Step 8: Test Application

### Test Todo Operations

1. **Open application**: http://localhost:3000 (or via minikube service)
2. **Sign up**: Create a new account
3. **Login**: Authenticate with credentials
4. **Create task**: "Buy groceries"
5. **AI interaction**: "Add a task to call mom tomorrow"
6. **List tasks**: Verify both tasks appear
7. **Complete task**: Mark "Buy groceries" as done
8. **Delete task**: Remove completed task

### Test Scaling

```bash
# Check current replicas
kubectl get hpa

# Generate load (requires hey or ab tool)
hey -z 60s -c 50 http://$(minikube ip):$(kubectl get svc todo-backend -o jsonpath='{.spec.ports[0].nodePort}')/health

# Watch HPA scale up
kubectl get hpa --watch

# Verify new pods created
kubectl get pods -l app=todo-backend
```

---

## Troubleshooting

### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Use kubectl-ai for diagnosis
kubectl ai "why is pod <pod-name> not starting?"
```

### Image Pull Errors

```bash
# Verify images exist locally
docker images | grep todo

# Rebuild if needed
docker build -t todo-frontend:latest ./frontend
docker build -t todo-backend:latest ./backend

# Ensure Minikube uses Docker Desktop images
eval $(minikube docker-env)
```

### Secret Not Found

```bash
# Check secret exists
kubectl get secret backend-secrets

# Recreate if missing
kubectl create secret generic backend-secrets \
  --from-literal=database_url="$DATABASE_URL" \
  --from-literal=cohere_api_key="$COHERE_API_KEY" \
  --from-literal=jwt_secret="$JWT_SECRET"
```

### Database Connection Failed

```bash
# Test database connectivity from pod
kubectl exec -it deployment/todo-backend -- sh
# Inside pod:
# python -c "import psycopg2; psycopg2.connect('$DATABASE_URL')"

# Check database URL format
kubectl get secret backend-secrets -o jsonpath='{.data.database_url}' | base64 --decode
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl get apiservice v1beta1.metrics.k8s.io

# Check pod metrics
kubectl top pods

# If metrics unavailable, restart metrics server
kubectl rollout restart deployment metrics-server -n kube-system
```

---

## Cleanup

### Delete Deployments

```bash
# Uninstall Helm releases
helm uninstall todo-frontend
helm uninstall todo-backend

# Delete secrets
kubectl delete secret backend-secrets

# Verify cleanup
kubectl get all
```

### Stop Minikube

```bash
# Stop cluster (preserves state)
minikube stop

# Delete cluster (removes all data)
minikube delete
```

---

## Next Steps

- **Production Deployment**: Adapt for cloud Kubernetes (EKS, GKE, AKS)
- **CI/CD Integration**: Automate builds and deployments
- **Monitoring**: Add Prometheus and Grafana
- **Logging**: Set up ELK or Loki stack
- **Security**: Implement network policies and pod security policies

---

## Quick Reference

### Common Commands

```bash
# Check cluster status
minikube status
kubectl get nodes

# View all resources
kubectl get all

# Check pod logs
kubectl logs -f deployment/todo-backend

# Restart deployment
kubectl rollout restart deployment/todo-backend

# Scale manually
kubectl scale deployment/todo-backend --replicas=3

# Port forward
kubectl port-forward service/todo-frontend 3000:3000

# Access via Minikube
minikube service todo-frontend

# Use kubectl-ai
kubectl ai "show me all failing pods"
kubectl ai "why is the backend crashing?"

# Use kagent
kagent analyze
kagent diagnose
```

### Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:
```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias mk='minikube'
```

---

**Quick Start Version**: 1.0.0
**Last Updated**: 2026-02-16
**Estimated Time**: 30 minutes
**Status**: ✅ Complete
