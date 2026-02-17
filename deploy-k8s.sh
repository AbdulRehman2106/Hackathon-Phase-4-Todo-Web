#!/bin/bash
# Kubernetes Deployment Script for Todo Application
# Phase 4: Cloud-Native Deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="todo-app"
BACKEND_IMAGE="phase4-backend:latest"
FRONTEND_IMAGE="phase4-frontend:latest"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Todo App Kubernetes Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo "Please ensure your cluster is running and kubectl is configured"
    exit 1
fi

echo -e "${GREEN}✓ Kubernetes cluster is accessible${NC}"

# Check if using Minikube
if kubectl config current-context | grep -q "minikube"; then
    echo -e "${YELLOW}Detected Minikube cluster${NC}"
    USING_MINIKUBE=true

    # Load images into Minikube
    echo "Loading Docker images into Minikube..."
    minikube image load $BACKEND_IMAGE || echo -e "${YELLOW}Warning: Failed to load backend image${NC}"
    minikube image load $FRONTEND_IMAGE || echo -e "${YELLOW}Warning: Failed to load frontend image${NC}"
    echo -e "${GREEN}✓ Images loaded into Minikube${NC}"
else
    USING_MINIKUBE=false
fi

# Check if secrets file exists
if [ ! -f "k8s/base/secrets.yaml" ]; then
    echo -e "${YELLOW}Warning: k8s/base/secrets.yaml not found${NC}"
    echo "Please create it from k8s/base/secrets.yaml.example"
    echo ""
    read -p "Do you want to continue without secrets? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    SKIP_SECRETS=true
else
    SKIP_SECRETS=false
fi

# Create namespace
echo ""
echo "Creating namespace..."
kubectl apply -f k8s/base/namespace.yaml
echo -e "${GREEN}✓ Namespace created${NC}"

# Apply secrets
if [ "$SKIP_SECRETS" = false ]; then
    echo ""
    echo "Applying secrets..."
    kubectl apply -f k8s/base/secrets.yaml
    echo -e "${GREEN}✓ Secrets applied${NC}"
fi

# Apply ConfigMap
echo ""
echo "Applying ConfigMap..."
kubectl apply -f k8s/base/configmap.yaml
echo -e "${GREEN}✓ ConfigMap applied${NC}"

# Deploy backend
echo ""
echo "Deploying backend..."
kubectl apply -f k8s/base/backend-deployment.yaml
kubectl apply -f k8s/base/backend-service.yaml
echo -e "${GREEN}✓ Backend deployed${NC}"

# Deploy frontend
echo ""
echo "Deploying frontend..."
kubectl apply -f k8s/base/frontend-deployment.yaml
kubectl apply -f k8s/base/frontend-service.yaml
echo -e "${GREEN}✓ Frontend deployed${NC}"

# Wait for deployments to be ready
echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n $NAMESPACE || echo -e "${YELLOW}Warning: Backend deployment timeout${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n $NAMESPACE || echo -e "${YELLOW}Warning: Frontend deployment timeout${NC}"

# Show deployment status
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Status${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

kubectl get all -n $NAMESPACE

# Get service URLs
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Access Information${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ "$USING_MINIKUBE" = true ]; then
    echo "Frontend URL:"
    minikube service frontend-service -n $NAMESPACE --url
    echo ""
    echo "To open in browser, run:"
    echo "  minikube service frontend-service -n $NAMESPACE"
else
    FRONTEND_PORT=$(kubectl get service frontend-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].port}')
    echo "Frontend Service: http://localhost:$FRONTEND_PORT"
    echo ""
    echo "If using LoadBalancer, get external IP with:"
    echo "  kubectl get service frontend-service -n $NAMESPACE"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Useful Commands${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "View logs:"
echo "  kubectl logs -n $NAMESPACE -l component=backend --tail=100 -f"
echo "  kubectl logs -n $NAMESPACE -l component=frontend --tail=100 -f"
echo ""
echo "Check pod status:"
echo "  kubectl get pods -n $NAMESPACE"
echo ""
echo "Scale deployments:"
echo "  kubectl scale deployment backend -n $NAMESPACE --replicas=3"
echo "  kubectl scale deployment frontend -n $NAMESPACE --replicas=3"
echo ""
echo "Delete deployment:"
echo "  kubectl delete namespace $NAMESPACE"
echo ""

echo -e "${GREEN}✓ Deployment complete!${NC}"
