@echo off
REM Kubernetes Deployment Script for Todo Application (Windows)
REM Phase 4: Cloud-Native Deployment

setlocal enabledelayedexpansion

set NAMESPACE=todo-app
set BACKEND_IMAGE=phase4-backend:latest
set FRONTEND_IMAGE=phase4-frontend:latest

echo ========================================
echo Todo App Kubernetes Deployment
echo ========================================
echo.

REM Check if kubectl is installed
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo Error: kubectl is not installed
    exit /b 1
)

REM Check if cluster is accessible
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo Error: Cannot connect to Kubernetes cluster
    echo Please ensure your cluster is running and kubectl is configured
    exit /b 1
)

echo [OK] Kubernetes cluster is accessible
echo.

REM Check if using Minikube
kubectl config current-context | findstr /C:"minikube" >nul
if not errorlevel 1 (
    echo Detected Minikube cluster
    echo Loading Docker images into Minikube...
    minikube image load %BACKEND_IMAGE%
    minikube image load %FRONTEND_IMAGE%
    echo [OK] Images loaded into Minikube
    set USING_MINIKUBE=true
) else (
    set USING_MINIKUBE=false
)

REM Check if secrets file exists
if not exist "k8s\base\secrets.yaml" (
    echo Warning: k8s\base\secrets.yaml not found
    echo Please create it from k8s\base\secrets.yaml.example
    echo.
    set /p CONTINUE="Do you want to continue without secrets? (y/N): "
    if /i not "!CONTINUE!"=="y" exit /b 1
    set SKIP_SECRETS=true
) else (
    set SKIP_SECRETS=false
)

REM Create namespace
echo.
echo Creating namespace...
kubectl apply -f k8s\base\namespace.yaml
echo [OK] Namespace created

REM Apply secrets
if not "%SKIP_SECRETS%"=="true" (
    echo.
    echo Applying secrets...
    kubectl apply -f k8s\base\secrets.yaml
    echo [OK] Secrets applied
)

REM Apply ConfigMap
echo.
echo Applying ConfigMap...
kubectl apply -f k8s\base\configmap.yaml
echo [OK] ConfigMap applied

REM Deploy backend
echo.
echo Deploying backend...
kubectl apply -f k8s\base\backend-deployment.yaml
kubectl apply -f k8s\base\backend-service.yaml
echo [OK] Backend deployed

REM Deploy frontend
echo.
echo Deploying frontend...
kubectl apply -f k8s\base\frontend-deployment.yaml
kubectl apply -f k8s\base\frontend-service.yaml
echo [OK] Frontend deployed

REM Wait for deployments
echo.
echo Waiting for deployments to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/backend -n %NAMESPACE%
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n %NAMESPACE%

REM Show deployment status
echo.
echo ========================================
echo Deployment Status
echo ========================================
echo.
kubectl get all -n %NAMESPACE%

REM Get service URLs
echo.
echo ========================================
echo Access Information
echo ========================================
echo.

if "%USING_MINIKUBE%"=="true" (
    echo Frontend URL:
    minikube service frontend-service -n %NAMESPACE% --url
    echo.
    echo To open in browser, run:
    echo   minikube service frontend-service -n %NAMESPACE%
) else (
    echo Frontend Service: http://localhost:3000
    echo.
    echo If using LoadBalancer, get external IP with:
    echo   kubectl get service frontend-service -n %NAMESPACE%
)

echo.
echo ========================================
echo Useful Commands
echo ========================================
echo.
echo View logs:
echo   kubectl logs -n %NAMESPACE% -l component=backend --tail=100 -f
echo   kubectl logs -n %NAMESPACE% -l component=frontend --tail=100 -f
echo.
echo Check pod status:
echo   kubectl get pods -n %NAMESPACE%
echo.
echo Scale deployments:
echo   kubectl scale deployment backend -n %NAMESPACE% --replicas=3
echo   kubectl scale deployment frontend -n %NAMESPACE% --replicas=3
echo.
echo Delete deployment:
echo   kubectl delete namespace %NAMESPACE%
echo.

echo [OK] Deployment complete!
