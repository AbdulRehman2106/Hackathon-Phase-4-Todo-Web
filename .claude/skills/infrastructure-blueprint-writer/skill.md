# Infrastructure Blueprint Writer Skill

## Skill ID
`infrastructure-blueprint-writer`

## Category
🏗 Spec-Driven Development

## Responsibility
Convert specification into infrastructure blueprint, create YAML structured infrastructure design, and establish the foundation for implementation planning.

## Inputs

```yaml
inputs:
  specification:
    path: string                # Path to spec.md
    content: string             # Spec content
    feature_name: string
  project_context:
    architecture: string        # "monorepo" | "microservices"
    tech_stack: object
    deployment_target: string   # "kubernetes" | "docker" | "serverless"
  requirements:
    functional: array
    non_functional: array
    constraints: array
```

## Outputs

```yaml
outputs:
  infrastructure_blueprint:
    path: string                # specs/<feature>/infrastructure.yaml
    structure: object
    components: array
    dependencies: array
```

## Algorithm

1. **Specification Analysis**
   - Parse spec.md content
   - Extract functional requirements
   - Identify non-functional requirements
   - Determine system boundaries

2. **Component Identification**
   - Identify frontend components
   - Identify backend services
   - Identify data stores
   - Identify external dependencies

3. **Infrastructure Design**
   - Define containerization strategy
   - Design Kubernetes resources
   - Plan networking and ingress
   - Configure observability

4. **Blueprint Generation**
   - Generate YAML structure
   - Document component relationships
   - Specify resource requirements
   - Define deployment strategy

## Infrastructure Blueprint Schema

```yaml
# specs/<feature>/infrastructure.yaml

metadata:
  feature_name: "{{FEATURE_NAME}}"
  version: "1.0.0"
  created_at: "{{TIMESTAMP}}"
  architecture: "{{ARCHITECTURE_TYPE}}"

components:
  frontend:
    - name: "{{FRONTEND_NAME}}"
      type: "nextjs"
      runtime: "node:20-alpine"
      port: 3000
      environment_variables:
        - NEXT_PUBLIC_API_URL
        - NEXT_PUBLIC_APP_NAME
      dependencies:
        - backend-api
      build:
        dockerfile: "frontend/Dockerfile"
        context: "./frontend"
      deployment:
        replicas: 2
        resources:
          requests:
            cpu: "100m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"

  backend:
    - name: "{{BACKEND_NAME}}"
      type: "fastapi"
      runtime: "python:3.11-slim"
      port: 8000
      environment_variables:
        - DATABASE_URL
        - REDIS_URL
        - JWT_SECRET
        - COHERE_API_KEY
      dependencies:
        - database
        - redis
        - cohere-api
      build:
        dockerfile: "backend/Dockerfile"
        context: "./backend"
      deployment:
        replicas: 3
        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "1000m"
            memory: "1Gi"
        health_checks:
          liveness:
            path: "/health"
            initial_delay: 30
          readiness:
            path: "/ready"
            initial_delay: 10

  databases:
    - name: "postgres"
      type: "postgresql"
      version: "15"
      storage: "10Gi"
      backup_enabled: true
      high_availability: false

    - name: "redis"
      type: "redis"
      version: "7"
      storage: "5Gi"
      persistence: true

  external_services:
    - name: "cohere-api"
      type: "external"
      endpoint: "https://api.cohere.ai"
      authentication: "api_key"
      rate_limits:
        requests_per_minute: 100

networking:
  ingress:
    enabled: true
    class: "nginx"
    tls_enabled: true
    rules:
      - host: "{{DOMAIN}}"
        paths:
          - path: "/"
            service: "frontend"
            port: 3000
          - path: "/api"
            service: "backend"
            port: 8000

  service_mesh:
    enabled: false
    type: "istio"

observability:
  logging:
    format: "json"
    level: "info"
    aggregation: "fluentd"

  metrics:
    enabled: true
    exporter: "prometheus"
    scrape_interval: "15s"

  tracing:
    enabled: true
    backend: "jaeger"
    sample_rate: 0.1

security:
  secrets:
    management: "sealed-secrets"
    rotation_policy: "90d"

  rbac:
    enabled: true
    service_accounts:
      - name: "frontend-sa"
        permissions: ["read:secrets", "read:configmaps"]
      - name: "backend-sa"
        permissions: ["read:secrets", "read:configmaps", "write:logs"]

  network_policies:
    enabled: true
    default_deny: true
    allowed_connections:
      - from: "frontend"
        to: "backend"
      - from: "backend"
        to: "database"
      - from: "backend"
        to: "redis"

deployment:
  strategy: "rolling_update"
  max_surge: "25%"
  max_unavailable: "25%"

  environments:
    development:
      namespace: "dev"
      replicas:
        frontend: 1
        backend: 1
      resources: "minimal"

    staging:
      namespace: "staging"
      replicas:
        frontend: 2
        backend: 2
      resources: "standard"

    production:
      namespace: "production"
      replicas:
        frontend: 3
        backend: 3
      resources: "optimized"
      autoscaling:
        enabled: true
        min_replicas: 3
        max_replicas: 10
        target_cpu: 80

ci_cd:
  pipeline: "github-actions"
  stages:
    - build
    - test
    - security-scan
    - deploy

  build:
    docker_registry: "ghcr.io"
    image_tagging: "git-sha"

  deployment:
    tool: "helm"
    chart_version: "1.0.0"
```

## Blueprint Generator Implementation

```typescript
interface Specification {
  feature_name: string;
  functional_requirements: string[];
  non_functional_requirements: string[];
  tech_stack: {
    frontend?: string;
    backend?: string;
    database?: string;
    cache?: string;
  };
  deployment_target: string;
}

class InfrastructureBlueprintWriter {
  generateBlueprint(spec: Specification): InfrastructureBlueprint {
    return {
      metadata: this.generateMetadata(spec),
      components: this.identifyComponents(spec),
      networking: this.designNetworking(spec),
      observability: this.configureObservability(spec),
      security: this.defineSecurity(spec),
      deployment: this.planDeployment(spec),
      ci_cd: this.configureCICD(spec)
    };
  }

  private generateMetadata(spec: Specification): any {
    return {
      feature_name: spec.feature_name,
      version: '1.0.0',
      created_at: new Date().toISOString(),
      architecture: this.detectArchitecture(spec)
    };
  }

  private identifyComponents(spec: Specification): any {
    const components: any = {};

    // Frontend component
    if (spec.tech_stack.frontend) {
      components.frontend = [{
        name: `${spec.feature_name}-frontend`,
        type: spec.tech_stack.frontend,
        runtime: this.getRuntimeForTech(spec.tech_stack.frontend),
        port: 3000,
        environment_variables: this.extractFrontendEnvVars(spec),
        dependencies: ['backend-api'],
        build: {
          dockerfile: 'frontend/Dockerfile',
          context: './frontend'
        },
        deployment: this.getDefaultDeploymentConfig('frontend')
      }];
    }

    // Backend component
    if (spec.tech_stack.backend) {
      components.backend = [{
        name: `${spec.feature_name}-backend`,
        type: spec.tech_stack.backend,
        runtime: this.getRuntimeForTech(spec.tech_stack.backend),
        port: 8000,
        environment_variables: this.extractBackendEnvVars(spec),
        dependencies: this.identifyBackendDependencies(spec),
        build: {
          dockerfile: 'backend/Dockerfile',
          context: './backend'
        },
        deployment: this.getDefaultDeploymentConfig('backend')
      }];
    }

    // Database components
    if (spec.tech_stack.database || spec.tech_stack.cache) {
      components.databases = [];

      if (spec.tech_stack.database) {
        components.databases.push({
          name: spec.tech_stack.database,
          type: spec.tech_stack.database,
          version: this.getLatestVersion(spec.tech_stack.database),
          storage: '10Gi',
          backup_enabled: true
        });
      }

      if (spec.tech_stack.cache) {
        components.databases.push({
          name: spec.tech_stack.cache,
          type: spec.tech_stack.cache,
          version: this.getLatestVersion(spec.tech_stack.cache),
          storage: '5Gi',
          persistence: true
        });
      }
    }

    // External services
    components.external_services = this.identifyExternalServices(spec);

    return components;
  }

  private designNetworking(spec: Specification): any {
    return {
      ingress: {
        enabled: true,
        class: 'nginx',
        tls_enabled: spec.deployment_target === 'kubernetes',
        rules: this.generateIngressRules(spec)
      },
      service_mesh: {
        enabled: false,
        type: 'istio'
      }
    };
  }

  private configureObservability(spec: Specification): any {
    return {
      logging: {
        format: 'json',
        level: 'info',
        aggregation: 'fluentd'
      },
      metrics: {
        enabled: true,
        exporter: 'prometheus',
        scrape_interval: '15s'
      },
      tracing: {
        enabled: this.requiresTracing(spec),
        backend: 'jaeger',
        sample_rate: 0.1
      }
    };
  }

  private defineSecurity(spec: Specification): any {
    return {
      secrets: {
        management: 'sealed-secrets',
        rotation_policy: '90d'
      },
      rbac: {
        enabled: true,
        service_accounts: this.generateServiceAccounts(spec)
      },
      network_policies: {
        enabled: true,
        default_deny: true,
        allowed_connections: this.defineAllowedConnections(spec)
      }
    };
  }

  private planDeployment(spec: Specification): any {
    return {
      strategy: 'rolling_update',
      max_surge: '25%',
      max_unavailable: '25%',
      environments: {
        development: this.getEnvironmentConfig('development', spec),
        staging: this.getEnvironmentConfig('staging', spec),
        production: this.getEnvironmentConfig('production', spec)
      }
    };
  }

  private configureCICD(spec: Specification): any {
    return {
      pipeline: 'github-actions',
      stages: ['build', 'test', 'security-scan', 'deploy'],
      build: {
        docker_registry: 'ghcr.io',
        image_tagging: 'git-sha'
      },
      deployment: {
        tool: 'helm',
        chart_version: '1.0.0'
      }
    };
  }

  private getRuntimeForTech(tech: string): string {
    const runtimeMap: Record<string, string> = {
      'nextjs': 'node:20-alpine',
      'react': 'node:20-alpine',
      'fastapi': 'python:3.11-slim',
      'express': 'node:20-alpine',
      'django': 'python:3.11-slim'
    };
    return runtimeMap[tech] || 'node:20-alpine';
  }

  private getDefaultDeploymentConfig(component: string): any {
    const configs: Record<string, any> = {
      frontend: {
        replicas: 2,
        resources: {
          requests: { cpu: '100m', memory: '256Mi' },
          limits: { cpu: '500m', memory: '512Mi' }
        }
      },
      backend: {
        replicas: 3,
        resources: {
          requests: { cpu: '250m', memory: '512Mi' },
          limits: { cpu: '1000m', memory: '1Gi' }
        },
        health_checks: {
          liveness: { path: '/health', initial_delay: 30 },
          readiness: { path: '/ready', initial_delay: 10 }
        }
      }
    };
    return configs[component];
  }

  writeBlueprint(blueprint: InfrastructureBlueprint, outputPath: string): void {
    const yaml = this.convertToYAML(blueprint);
    fs.writeFileSync(outputPath, yaml, 'utf-8');
  }
}
```

## Usage Example

```typescript
// Parse specification
const spec: Specification = {
  feature_name: 'todo-management',
  functional_requirements: [
    'Users can create todos',
    'Users can list todos',
    'Users can update todos',
    'Users can delete todos'
  ],
  non_functional_requirements: [
    'Response time < 200ms',
    'Support 1000 concurrent users',
    '99.9% uptime'
  ],
  tech_stack: {
    frontend: 'nextjs',
    backend: 'fastapi',
    database: 'postgresql',
    cache: 'redis'
  },
  deployment_target: 'kubernetes'
};

// Generate blueprint
const writer = new InfrastructureBlueprintWriter();
const blueprint = writer.generateBlueprint(spec);

// Write to file
writer.writeBlueprint(
  blueprint,
  'specs/todo-management/infrastructure.yaml'
);
```

## Blueprint Validation

```yaml
validation_rules:
  completeness:
    - "All components have build configuration"
    - "All components have deployment configuration"
    - "All dependencies are declared"
    - "All environment variables are listed"

  consistency:
    - "Port numbers don't conflict"
    - "Resource names follow naming convention"
    - "Dependencies reference existing components"

  security:
    - "Secrets are not hardcoded"
    - "RBAC is configured"
    - "Network policies are defined"
    - "TLS is enabled for production"

  scalability:
    - "Resource limits are defined"
    - "Autoscaling is configured for production"
    - "Health checks are present"
```

## Integration Points

- **Depends On**: Specification document (spec.md)
- **Next Skill**: `task-breakdown-engine` (task generation)
- **Outputs To**: specs/<feature>/infrastructure.yaml

## Performance Targets

- Blueprint generation: < 5 seconds
- Validation: < 2 seconds
- File write: < 1 second

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
