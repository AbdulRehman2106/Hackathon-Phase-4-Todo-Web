# Ingress Configurator Skill

## Skill ID
`ingress-configurator`

## Category
☸️ Kubernetes

## Responsibility
Configure Minikube ingress, domain mapping, TLS optional configuration, and external access routing for Kubernetes services.

## Inputs

```yaml
inputs:
  application:
    name: string
    service_name: string
    service_port: integer
  ingress:
    enabled: boolean
    class_name: string          # "nginx" | "traefik" | "istio"
    host: string                # Domain name
    path: string                # URL path (default: "/")
    path_type: string           # "Prefix" | "Exact" | "ImplementationSpecific"
  tls:
    enabled: boolean
    secret_name: string
    cert_manager: boolean       # Use cert-manager for auto TLS
  annotations: object           # Custom ingress annotations
  environment: string           # "development" | "staging" | "production"
```

## Outputs

```yaml
outputs:
  ingress_config:
    manifest: string            # YAML ingress manifest
    ingress_class: string
    rules: array
    tls_config: object
  exposure_strategy:
    access_method: string       # "minikube tunnel" | "LoadBalancer" | "NodePort"
    access_url: string
    setup_commands: array
```

## Algorithm

1. **Ingress Class Selection**
   - Detect available ingress controllers
   - Select appropriate class (nginx for Minikube)
   - Verify ingress controller is enabled

2. **Routing Rules Configuration**
   - Define host-based routing
   - Configure path-based routing
   - Set backend service references
   - Apply path type semantics

3. **TLS Configuration**
   - Generate self-signed cert (development)
   - Configure cert-manager (staging/production)
   - Create TLS secret
   - Apply HTTPS redirect

4. **Minikube-Specific Setup**
   - Enable ingress addon
   - Configure /etc/hosts for local domains
   - Set up minikube tunnel for LoadBalancer
   - Provide access instructions

## Ingress Manifest Template

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{APP_NAME}}-ingress
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
  annotations:
    {{#if NGINX}}
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "{{SSL_REDIRECT}}"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "{{FORCE_SSL}}"
    {{/if}}
    {{#if CERT_MANAGER}}
    cert-manager.io/cluster-issuer: "{{ISSUER_NAME}}"
    {{/if}}
    {{#if RATE_LIMIT}}
    nginx.ingress.kubernetes.io/limit-rps: "{{RATE_LIMIT}}"
    {{/if}}
    {{#each CUSTOM_ANNOTATIONS}}
    {{@key}}: "{{this}}"
    {{/each}}
spec:
  ingressClassName: {{INGRESS_CLASS}}
  {{#if TLS_ENABLED}}
  tls:
  - hosts:
    - {{HOST}}
    secretName: {{TLS_SECRET_NAME}}
  {{/if}}
  rules:
  - host: {{HOST}}
    http:
      paths:
      - path: {{PATH}}
        pathType: {{PATH_TYPE}}
        backend:
          service:
            name: {{SERVICE_NAME}}
            port:
              number: {{SERVICE_PORT}}
```

## Minikube Ingress Setup

```yaml
minikube_setup:
  # Step 1: Enable ingress addon
  enable_ingress:
    command: "minikube addons enable ingress"
    description: "Enable NGINX Ingress Controller"
    verification: "kubectl get pods -n ingress-nginx"

  # Step 2: Verify ingress controller
  verify_controller:
    command: "kubectl get pods -n ingress-nginx"
    expected: "ingress-nginx-controller pod running"

  # Step 3: Configure local DNS
  hosts_entry:
    file: "/etc/hosts"
    entry: "{{MINIKUBE_IP}} {{HOST}}"
    command: "echo '$(minikube ip) {{HOST}}' | sudo tee -a /etc/hosts"

  # Step 4: Start tunnel (for LoadBalancer)
  tunnel:
    command: "minikube tunnel"
    description: "Create route to services with type LoadBalancer"
    note: "Keep this running in separate terminal"

  # Step 5: Access application
  access:
    url: "http://{{HOST}}"
    curl_test: "curl -H 'Host: {{HOST}}' http://$(minikube ip)"
```

## TLS Configuration Strategies

```yaml
tls_strategies:
  development:
    method: "self-signed"
    setup: |
      # Generate self-signed certificate
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout tls.key -out tls.crt \
        -subj "/CN={{HOST}}/O={{APP_NAME}}"

      # Create Kubernetes secret
      kubectl create secret tls {{TLS_SECRET_NAME}} \
        --key tls.key --cert tls.crt \
        --namespace {{NAMESPACE}}
    verification: "kubectl get secret {{TLS_SECRET_NAME}}"

  staging:
    method: "cert-manager-staging"
    setup: |
      # Install cert-manager
      kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

      # Create staging issuer
      kubectl apply -f - <<EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-staging
      spec:
        acme:
          server: https://acme-staging-v02.api.letsencrypt.org/directory
          email: {{EMAIL}}
          privateKeySecretRef:
            name: letsencrypt-staging
          solvers:
          - http01:
              ingress:
                class: nginx
      EOF
    annotation: 'cert-manager.io/cluster-issuer: "letsencrypt-staging"'

  production:
    method: "cert-manager-production"
    setup: |
      # Create production issuer
      kubectl apply -f - <<EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-prod
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          email: {{EMAIL}}
          privateKeySecretRef:
            name: letsencrypt-prod
          solvers:
          - http01:
              ingress:
                class: nginx
      EOF
    annotation: 'cert-manager.io/cluster-issuer: "letsencrypt-prod"'
```

## Path-Based Routing Examples

```yaml
path_routing:
  single_service:
    description: "Route all traffic to one service"
    manifest: |
      rules:
      - host: example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80

  multiple_paths:
    description: "Route different paths to different services"
    manifest: |
      rules:
      - host: example.com
        http:
          paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: backend-api
                port:
                  number: 8080
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80

  subdomain_routing:
    description: "Route subdomains to different services"
    manifest: |
      rules:
      - host: api.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backend-api
                port:
                  number: 8080
      - host: www.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80
```

## Common Annotations

```yaml
nginx_annotations:
  ssl_redirect:
    annotation: "nginx.ingress.kubernetes.io/ssl-redirect"
    values: ["true", "false"]
    description: "Redirect HTTP to HTTPS"

  rewrite_target:
    annotation: "nginx.ingress.kubernetes.io/rewrite-target"
    example: "/$2"
    description: "Rewrite URL path before forwarding"

  rate_limiting:
    annotation: "nginx.ingress.kubernetes.io/limit-rps"
    example: "10"
    description: "Limit requests per second per IP"

  cors:
    annotations:
      - "nginx.ingress.kubernetes.io/enable-cors: 'true'"
      - "nginx.ingress.kubernetes.io/cors-allow-origin: '*'"
      - "nginx.ingress.kubernetes.io/cors-allow-methods: 'GET, POST, PUT, DELETE'"

  websocket:
    annotations:
      - "nginx.ingress.kubernetes.io/proxy-read-timeout: '3600'"
      - "nginx.ingress.kubernetes.io/proxy-send-timeout: '3600'"

  client_body_size:
    annotation: "nginx.ingress.kubernetes.io/proxy-body-size"
    example: "10m"
    description: "Max request body size"
```

## Exposure Strategy by Environment

```yaml
development:
  method: "minikube_tunnel"
  ingress_class: "nginx"
  tls: false
  setup_commands:
    - "minikube addons enable ingress"
    - "echo '$(minikube ip) {{HOST}}' | sudo tee -a /etc/hosts"
  access_url: "http://{{HOST}}"
  notes:
    - "Add host entry to /etc/hosts"
    - "Use HTTP (no TLS) for simplicity"

staging:
  method: "cloud_load_balancer"
  ingress_class: "nginx"
  tls: true
  tls_issuer: "letsencrypt-staging"
  setup_commands:
    - "kubectl apply -f ingress.yaml"
    - "kubectl get ingress -w"
  access_url: "https://staging.{{HOST}}"
  notes:
    - "DNS must point to LoadBalancer IP"
    - "Use Let's Encrypt staging for testing"

production:
  method: "cloud_load_balancer"
  ingress_class: "nginx"
  tls: true
  tls_issuer: "letsencrypt-prod"
  setup_commands:
    - "kubectl apply -f ingress.yaml"
    - "kubectl get ingress -w"
  access_url: "https://{{HOST}}"
  notes:
    - "DNS must point to LoadBalancer IP"
    - "Use Let's Encrypt production"
    - "Monitor certificate renewal"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl get ingress {{INGRESS_NAME}}"
    description: "Verify ingress resource created"
    success_criteria: "Ingress exists with ADDRESS assigned"

  - command: "kubectl describe ingress {{INGRESS_NAME}}"
    description: "Check ingress configuration details"
    success_criteria: "Rules and backend configured correctly"

  - command: "kubectl get svc -n ingress-nginx"
    description: "Verify ingress controller service"
    success_criteria: "ingress-nginx-controller service exists"

  - command: "curl -H 'Host: {{HOST}}' http://$(minikube ip)"
    description: "Test HTTP access (Minikube)"
    success_criteria: "HTTP 200 response"

  - command: "curl -k https://{{HOST}}"
    description: "Test HTTPS access"
    success_criteria: "HTTP 200 response with TLS"

  - command: "kubectl get certificate {{TLS_SECRET_NAME}}"
    description: "Verify cert-manager certificate (if enabled)"
    success_criteria: "Certificate in Ready state"
```

## Troubleshooting Guide

```yaml
common_issues:
  - issue: "Ingress has no ADDRESS"
    causes:
      - "Ingress controller not running"
      - "LoadBalancer service pending"
      - "Minikube tunnel not started"
    diagnosis: "kubectl get pods -n ingress-nginx"
    resolution: "Enable ingress addon or start minikube tunnel"

  - issue: "404 Not Found"
    causes:
      - "Incorrect path configuration"
      - "Service name mismatch"
      - "Backend service not ready"
    diagnosis: "kubectl describe ingress {{INGRESS_NAME}}"
    resolution: "Verify service name and path configuration"

  - issue: "TLS certificate not working"
    causes:
      - "cert-manager not installed"
      - "DNS not propagated"
      - "HTTP-01 challenge failing"
    diagnosis: "kubectl describe certificate {{TLS_SECRET_NAME}}"
    resolution: "Check cert-manager logs and DNS configuration"

  - issue: "Host header not matching"
    causes:
      - "/etc/hosts not configured"
      - "DNS not pointing to cluster"
    diagnosis: "curl -v -H 'Host: {{HOST}}' http://$(minikube ip)"
    resolution: "Add host entry or configure DNS"
```

## Integration Points

- **Depends On**: `kubernetes-deployment-designer` (service reference)
- **Next Skill**: `autoscaling-configurator` (HPA configuration)
- **Outputs To**: External access configuration

## Performance Targets

- Ingress creation: < 10 seconds
- TLS certificate issuance: < 2 minutes (cert-manager)
- DNS propagation: 5-60 minutes (external DNS)

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
