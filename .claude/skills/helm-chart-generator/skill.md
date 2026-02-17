# Helm Chart Generator Skill

## Skill ID
`helm-chart-generator`

## Category
☸️ Kubernetes

## Responsibility
Generate complete Helm chart structure including Chart.yaml, values.yaml, and templates for deployment, service, and ingress configurations.

## Inputs

```yaml
inputs:
  application:
    name: string                # Application name
    version: string             # Application version
    description: string         # Chart description
  container:
    image: string               # Container image reference
    tag: string                 # Image tag
    port: integer               # Container port
  deployment:
    replicas: integer           # Number of replicas
    resources:
      requests:
        cpu: string             # e.g., "100m"
        memory: string          # e.g., "128Mi"
      limits:
        cpu: string
        memory: string
  service:
    type: string                # "ClusterIP" | "NodePort" | "LoadBalancer"
    port: integer               # Service port
  ingress:
    enabled: boolean
    host: string                # Domain name
    tls_enabled: boolean
  environment: string           # "development" | "staging" | "production"
```

## Outputs

```yaml
outputs:
  helm_chart_structure:
    chart_path: string          # Root chart directory
    files_created: array        # List of generated files
    chart_version: string       # Helm chart version
  configuration_map:
    configurable_values: array  # List of values that can be overridden
    required_values: array      # Mandatory values
    default_values: object      # Default configuration
```

## Algorithm

1. **Chart Structure Creation**
   - Create standard Helm chart directory structure
   - Generate Chart.yaml with metadata
   - Create values.yaml with defaults
   - Generate template files

2. **Template Generation**
   - deployment.yaml: Pod specification
   - service.yaml: Service configuration
   - ingress.yaml: Ingress rules (if enabled)
   - _helpers.tpl: Template helpers
   - NOTES.txt: Post-install instructions

3. **Values Configuration**
   - Define sensible defaults
   - Support environment-specific overrides
   - Include resource limits
   - Configure probes and security

4. **Validation**
   - Helm lint check
   - Template rendering test
   - Values schema validation

## Helm Chart Directory Structure

```
{{CHART_NAME}}/
├── Chart.yaml
├── values.yaml
├── values-dev.yaml
├── values-staging.yaml
├── values-prod.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── NOTES.txt
└── .helmignore
```

## Chart.yaml Template

```yaml
apiVersion: v2
name: {{APPLICATION_NAME}}
description: {{DESCRIPTION}}
type: application
version: {{CHART_VERSION}}
appVersion: "{{APP_VERSION}}"

keywords:
  - {{APPLICATION_NAME}}
  - kubernetes
  - helm

maintainers:
  - name: DevOps Team
    email: devops@example.com

sources:
  - https://github.com/example/{{APPLICATION_NAME}}

annotations:
  category: Application
  licenses: Apache-2.0
```

## values.yaml Template

```yaml
# Default values for {{APPLICATION_NAME}}
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: {{REPLICAS}}

image:
  repository: {{IMAGE_REPOSITORY}}
  pullPolicy: IfNotPresent
  tag: "{{IMAGE_TAG}}"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup: 1001

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true

service:
  type: {{SERVICE_TYPE}}
  port: {{SERVICE_PORT}}
  targetPort: {{CONTAINER_PORT}}

ingress:
  enabled: {{INGRESS_ENABLED}}
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: {{INGRESS_HOST}}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: {{APPLICATION_NAME}}-tls
      hosts:
        - {{INGRESS_HOST}}

resources:
  limits:
    cpu: {{CPU_LIMIT}}
    memory: {{MEMORY_LIMIT}}
  requests:
    cpu: {{CPU_REQUEST}}
    memory: {{MEMORY_REQUEST}}

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}

livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

env: []
  # - name: NODE_ENV
  #   value: "production"

envFrom: []
  # - configMapRef:
  #     name: app-config
  # - secretRef:
  #     name: app-secrets
```

## templates/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "{{CHART_NAME}}.fullname" . }}
  labels:
    {{- include "{{CHART_NAME}}.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "{{CHART_NAME}}.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "{{CHART_NAME}}.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "{{CHART_NAME}}.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: {{ .Values.service.targetPort }}
          protocol: TCP
        livenessProbe:
          {{- toYaml .Values.livenessProbe | nindent 12 }}
        readinessProbe:
          {{- toYaml .Values.readinessProbe | nindent 12 }}
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
        {{- with .Values.env }}
        env:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        {{- with .Values.envFrom }}
        envFrom:
          {{- toYaml . | nindent 12 }}
        {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

## templates/service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "{{CHART_NAME}}.fullname" . }}
  labels:
    {{- include "{{CHART_NAME}}.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "{{CHART_NAME}}.selectorLabels" . | nindent 4 }}
```

## templates/ingress.yaml

```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "{{CHART_NAME}}.fullname" . }}
  labels:
    {{- include "{{CHART_NAME}}.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "{{CHART_NAME}}.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
```

## templates/_helpers.tpl

```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "{{CHART_NAME}}.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "{{CHART_NAME}}.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "{{CHART_NAME}}.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "{{CHART_NAME}}.labels" -}}
helm.sh/chart: {{ include "{{CHART_NAME}}.chart" . }}
{{ include "{{CHART_NAME}}.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "{{CHART_NAME}}.selectorLabels" -}}
app.kubernetes.io/name: {{ include "{{CHART_NAME}}.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "{{CHART_NAME}}.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "{{CHART_NAME}}.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

## Validation Commands

```yaml
validation_commands:
  - command: "helm lint {{CHART_PATH}}"
    description: "Validate chart syntax and structure"
    success_criteria: "No errors found"

  - command: "helm template {{CHART_NAME}} {{CHART_PATH}}"
    description: "Render templates without installation"
    success_criteria: "Valid Kubernetes manifests generated"

  - command: "helm install --dry-run --debug {{CHART_NAME}} {{CHART_PATH}}"
    description: "Simulate installation"
    success_criteria: "No errors, manifests rendered"

  - command: "kubeval <(helm template {{CHART_NAME}} {{CHART_PATH}})"
    description: "Validate Kubernetes manifests"
    success_criteria: "All manifests valid"
```

## Environment-Specific Values

```yaml
# values-dev.yaml
environment: development
replicaCount: 1
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
ingress:
  enabled: true
  host: dev.example.com

# values-staging.yaml
environment: staging
replicaCount: 2
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 250m
    memory: 256Mi
ingress:
  enabled: true
  host: staging.example.com

# values-prod.yaml
environment: production
replicaCount: 3
resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 512Mi
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
ingress:
  enabled: true
  host: example.com
  tls:
    enabled: true
```

## Integration Points

- **Depends On**: `docker-build-orchestrator` (image reference)
- **Next Skill**: `kubernetes-deployment-designer` (deployment configuration)
- **Outputs To**: Helm installation commands

## Performance Targets

- Chart generation: < 3 seconds
- Template validation: < 5 seconds
- Chart installation: < 30 seconds

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
