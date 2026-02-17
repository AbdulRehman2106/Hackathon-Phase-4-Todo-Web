# RBAC Configurator Skill

## Skill ID
`rbac-configurator`

## Category
🔐 Security

## Responsibility
Define service accounts, Role and RoleBinding configuration, implement least privilege principle, and establish secure access control for Kubernetes resources.

## Inputs

```yaml
inputs:
  application:
    name: string
    namespace: string
  access_requirements:
    resources: array            # ["pods", "secrets", "configmaps", "services"]
    verbs: array                # ["get", "list", "watch", "create", "update", "delete"]
    scope: string               # "namespace" | "cluster"
  service_account:
    name: string
    automount_token: boolean
  security_policy:
    least_privilege: boolean
    audit_enabled: boolean
```

## Outputs

```yaml
outputs:
  rbac_yaml:
    service_account: string
    role: string
    role_binding: string
  permission_matrix:
    allowed_actions: array
    denied_actions: array
    resource_access: object
```

## Algorithm

1. **Access Analysis**
   - Identify required resources
   - Determine necessary verbs
   - Assess scope (namespace vs cluster)
   - Apply least privilege principle

2. **Service Account Creation**
   - Generate service account
   - Configure token automounting
   - Add labels and annotations
   - Link to image pull secrets if needed

3. **Role Definition**
   - Define resource permissions
   - Specify allowed verbs
   - Set resource names (if specific)
   - Choose Role vs ClusterRole

4. **Binding Creation**
   - Bind role to service account
   - Verify binding scope
   - Test permissions
   - Document access grants

## RBAC Components

```yaml
rbac_components:
  ServiceAccount:
    description: "Identity for pods"
    scope: "Namespace"
    purpose: "Provides identity for running pods"

  Role:
    description: "Permissions within namespace"
    scope: "Namespace"
    purpose: "Defines what actions can be performed"

  ClusterRole:
    description: "Permissions across cluster"
    scope: "Cluster"
    purpose: "Defines cluster-wide permissions"

  RoleBinding:
    description: "Grants Role to subjects in namespace"
    scope: "Namespace"
    purpose: "Binds Role to ServiceAccount"

  ClusterRoleBinding:
    description: "Grants ClusterRole to subjects cluster-wide"
    scope: "Cluster"
    purpose: "Binds ClusterRole to ServiceAccount"
```

## Service Account Template

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{APP_NAME}}-sa
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
    component: service-account
  annotations:
    description: "Service account for {{APP_NAME}}"
automountServiceAccountToken: {{AUTOMOUNT_TOKEN}}
imagePullSecrets:
- name: {{REGISTRY_SECRET}}  # Optional
```

## Role Templates

### Read-Only Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{APP_NAME}}-reader
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
rules:
# Read pods
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

# Read pod logs
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]

# Read configmaps
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]

# Read secrets (specific ones only)
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["{{APP_NAME}}-secrets"]
  verbs: ["get"]
```

### Application Role (Standard)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{APP_NAME}}-role
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
rules:
# Manage own pods
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

# Read secrets
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["{{APP_NAME}}-secrets"]
  verbs: ["get"]

# Read configmaps
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["{{APP_NAME}}-config"]
  verbs: ["get", "list", "watch"]

# Access services
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
```

### Admin Role (Elevated)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{APP_NAME}}-admin
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
rules:
# Full pod management
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/exec"]
  verbs: ["*"]

# Manage secrets
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# Manage configmaps
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["*"]

# Manage services
- apiGroups: [""]
  resources: ["services"]
  verbs: ["*"]

# Manage deployments
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["*"]
```

## RoleBinding Template

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{APP_NAME}}-binding
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
subjects:
- kind: ServiceAccount
  name: {{APP_NAME}}-sa
  namespace: {{NAMESPACE}}
roleRef:
  kind: Role
  name: {{APP_NAME}}-role
  apiGroup: rbac.authorization.k8s.io
```

## ClusterRole for Cross-Namespace Access

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{APP_NAME}}-cluster-reader
  labels:
    app: {{APP_NAME}}
rules:
# Read nodes (cluster-wide)
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]

# Read namespaces
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]

# Read pods across namespaces
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{APP_NAME}}-cluster-binding
subjects:
- kind: ServiceAccount
  name: {{APP_NAME}}-sa
  namespace: {{NAMESPACE}}
roleRef:
  kind: ClusterRole
  name: {{APP_NAME}}-cluster-reader
  apiGroup: rbac.authorization.k8s.io
```

## Permission Matrix Generator

```typescript
interface PermissionRequirement {
  resource: string;
  verbs: string[];
  resourceNames?: string[];
  scope: 'namespace' | 'cluster';
}

class RBACConfigurator {
  generateRole(
    name: string,
    namespace: string,
    requirements: PermissionRequirement[]
  ): any {
    const rules = requirements
      .filter(req => req.scope === 'namespace')
      .map(req => ({
        apiGroups: this.getApiGroup(req.resource),
        resources: [req.resource],
        verbs: req.verbs,
        ...(req.resourceNames && { resourceNames: req.resourceNames })
      }));

    return {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'Role',
      metadata: {
        name,
        namespace,
        labels: {
          app: name,
          'managed-by': 'rbac-configurator'
        }
      },
      rules
    };
  }

  generateServiceAccount(name: string, namespace: string): any {
    return {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: {
        name: `${name}-sa`,
        namespace,
        labels: {
          app: name
        }
      },
      automountServiceAccountToken: true
    };
  }

  generateRoleBinding(
    name: string,
    namespace: string,
    roleName: string,
    serviceAccountName: string
  ): any {
    return {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'RoleBinding',
      metadata: {
        name: `${name}-binding`,
        namespace
      },
      subjects: [
        {
          kind: 'ServiceAccount',
          name: serviceAccountName,
          namespace
        }
      ],
      roleRef: {
        kind: 'Role',
        name: roleName,
        apiGroup: 'rbac.authorization.k8s.io'
      }
    };
  }

  private getApiGroup(resource: string): string[] {
    const coreResources = [
      'pods', 'services', 'configmaps', 'secrets',
      'persistentvolumeclaims', 'serviceaccounts'
    ];

    if (coreResources.includes(resource)) {
      return [''];
    }

    if (resource.includes('deployment') || resource.includes('replicaset')) {
      return ['apps'];
    }

    if (resource.includes('ingress')) {
      return ['networking.k8s.io'];
    }

    return [''];
  }

  validatePermissions(role: any): ValidationResult {
    const warnings: string[] = [];
    const errors: string[] = [];

    for (const rule of role.rules) {
      // Check for overly permissive rules
      if (rule.verbs.includes('*')) {
        warnings.push('Rule uses wildcard verb (*) - consider being more specific');
      }

      if (rule.resources.includes('*')) {
        warnings.push('Rule uses wildcard resource (*) - violates least privilege');
      }

      // Check for dangerous permissions
      if (rule.resources.includes('secrets') && rule.verbs.includes('*')) {
        errors.push('Full access to secrets is dangerous');
      }

      if (rule.resources.includes('pods/exec') && !rule.resourceNames) {
        warnings.push('Unrestricted pod exec access - potential security risk');
      }
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }
}
```

## Common RBAC Patterns

```yaml
patterns:
  application_pod:
    description: "Standard application pod permissions"
    permissions:
      - resource: "secrets"
        verbs: ["get"]
        resourceNames: ["app-secrets"]
      - resource: "configmaps"
        verbs: ["get", "list", "watch"]
      - resource: "services"
        verbs: ["get", "list"]

  ci_cd_deployer:
    description: "CI/CD pipeline deployment permissions"
    permissions:
      - resource: "deployments"
        verbs: ["get", "list", "create", "update", "patch"]
      - resource: "services"
        verbs: ["get", "list", "create", "update"]
      - resource: "configmaps"
        verbs: ["get", "list", "create", "update"]
      - resource: "secrets"
        verbs: ["get", "list"]

  monitoring_agent:
    description: "Monitoring/observability agent permissions"
    permissions:
      - resource: "pods"
        verbs: ["get", "list", "watch"]
      - resource: "pods/log"
        verbs: ["get"]
      - resource: "nodes"
        verbs: ["get", "list"]
      - resource: "services"
        verbs: ["get", "list"]

  backup_operator:
    description: "Backup operator permissions"
    permissions:
      - resource: "persistentvolumeclaims"
        verbs: ["get", "list"]
      - resource: "persistentvolumes"
        verbs: ["get", "list"]
      - resource: "pods"
        verbs: ["get", "list"]
```

## Least Privilege Examples

```yaml
least_privilege:
  bad_example:
    description: "Overly permissive - grants unnecessary access"
    rules:
      - apiGroups: ["*"]
        resources: ["*"]
        verbs: ["*"]
    issues:
      - "Wildcard access to all resources"
      - "Violates least privilege principle"
      - "Security risk"

  good_example:
    description: "Minimal permissions - only what's needed"
    rules:
      - apiGroups: [""]
        resources: ["secrets"]
        resourceNames: ["app-secrets"]
        verbs: ["get"]
      - apiGroups: [""]
        resources: ["configmaps"]
        resourceNames: ["app-config"]
        verbs: ["get", "list", "watch"]
    benefits:
      - "Specific resources only"
      - "Named resources where possible"
      - "Minimal verbs"
      - "Follows least privilege"
```

## Testing RBAC Permissions

```yaml
testing:
  can_i_command:
    description: "Test if service account can perform action"
    examples:
      - command: "kubectl auth can-i get secrets --as=system:serviceaccount:default:app-sa"
        expected: "yes or no"

      - command: "kubectl auth can-i create pods --as=system:serviceaccount:default:app-sa"
        expected: "yes or no"

      - command: "kubectl auth can-i delete deployments --as=system:serviceaccount:default:app-sa"
        expected: "no (if properly restricted)"

  impersonation_testing:
    description: "Test permissions by impersonating service account"
    command: |
      kubectl get pods \
        --as=system:serviceaccount:default:app-sa \
        --as-group=system:authenticated

  audit_permissions:
    description: "List all permissions for service account"
    command: |
      kubectl describe role app-role
      kubectl describe rolebinding app-binding
```

## Security Best Practices

```yaml
best_practices:
  service_accounts:
    - "Create dedicated service account per application"
    - "Don't use default service account"
    - "Disable token automounting if not needed"
    - "Use separate service accounts for different components"

  roles:
    - "Apply least privilege principle"
    - "Use specific resource names when possible"
    - "Avoid wildcard permissions (*)"
    - "Prefer Role over ClusterRole when possible"
    - "Document why each permission is needed"

  bindings:
    - "Bind to service accounts, not users"
    - "Use RoleBinding for namespace scope"
    - "Audit bindings regularly"
    - "Remove unused bindings"

  monitoring:
    - "Enable audit logging"
    - "Monitor for permission denials"
    - "Alert on privilege escalation attempts"
    - "Review permissions quarterly"
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl get serviceaccount {{SA_NAME}}"
    description: "Verify service account exists"
    success_criteria: "Service account found"

  - command: "kubectl get role {{ROLE_NAME}}"
    description: "Verify role exists"
    success_criteria: "Role found with correct rules"

  - command: "kubectl get rolebinding {{BINDING_NAME}}"
    description: "Verify role binding exists"
    success_criteria: "Binding links role to service account"

  - command: "kubectl auth can-i --list --as=system:serviceaccount:{{NAMESPACE}}:{{SA_NAME}}"
    description: "List all permissions for service account"
    success_criteria: "Permissions match requirements"

  - command: "kubectl describe role {{ROLE_NAME}}"
    description: "View detailed role permissions"
    success_criteria: "Rules follow least privilege"
```

## Integration Points

- **Depends On**: `secrets-manager-config` (secret access)
- **Next Skill**: `infrastructure-blueprint-writer` (spec-driven development)
- **Outputs To**: Kubernetes RBAC system, pod security

## Performance Targets

- RBAC creation: < 2 seconds
- Permission check: < 100ms
- Role binding: < 1 second
- Permission propagation: < 5 seconds

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
