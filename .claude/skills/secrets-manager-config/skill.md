# Secrets Manager Config Skill

## Skill ID
`secrets-manager-config`

## Category
🔐 Security

## Responsibility
Convert .env to Kubernetes secrets, secure API storage, restrict secret exposure, and implement secure secret management for cloud-native applications.

## Inputs

```yaml
inputs:
  secrets_source:
    type: string                # "env_file" | "manual" | "vault"
    path: string                # Path to .env file or vault path
  application:
    name: string
    namespace: string
  encryption:
    enabled: boolean
    method: string              # "sealed-secrets" | "external-secrets" | "native"
  access_control:
    service_accounts: array
    rbac_enabled: boolean
```

## Outputs

```yaml
outputs:
  secret_manifest:
    kubernetes_secret: string   # YAML manifest
    sealed_secret: string       # Encrypted version (if applicable)
    access_policy: string       # RBAC policy
  encryption_strategy:
    method: string
    key_rotation: object
    audit_logging: boolean
```

## Algorithm

1. **Secret Extraction**
   - Parse .env file or source
   - Validate secret format
   - Identify sensitive values
   - Categorize secrets by type

2. **Secret Encryption**
   - Encode secrets in base64
   - Apply encryption (if using sealed-secrets)
   - Generate encrypted manifest
   - Store encryption keys securely

3. **Kubernetes Secret Creation**
   - Generate Secret manifest
   - Apply RBAC policies
   - Configure service account access
   - Set up secret rotation

4. **Access Control**
   - Define who can access secrets
   - Implement least privilege
   - Enable audit logging
   - Monitor secret usage

## Secret Types

```yaml
secret_types:
  opaque:
    description: "Generic secret (default)"
    use_cases:
      - "API keys"
      - "Database passwords"
      - "Encryption keys"
    example: |
      apiVersion: v1
      kind: Secret
      metadata:
        name: app-secrets
      type: Opaque
      data:
        api-key: YWJjMTIzZGVmNDU2  # base64 encoded

  docker-registry:
    description: "Docker registry credentials"
    use_cases:
      - "Private container registry access"
    example: |
      apiVersion: v1
      kind: Secret
      metadata:
        name: registry-credentials
      type: kubernetes.io/dockerconfigjson
      data:
        .dockerconfigjson: eyJhdXRocyI6e...

  tls:
    description: "TLS certificate and key"
    use_cases:
      - "HTTPS ingress"
      - "Service mesh certificates"
    example: |
      apiVersion: v1
      kind: Secret
      metadata:
        name: tls-secret
      type: kubernetes.io/tls
      data:
        tls.crt: LS0tLS1CRUdJTi...
        tls.key: LS0tLS1CRUdJTi...

  service-account-token:
    description: "Service account token"
    use_cases:
      - "Kubernetes API access"
    managed_by: "Kubernetes (automatic)"
```

## .env to Kubernetes Secret Converter

```typescript
interface EnvSecret {
  key: string;
  value: string;
  sensitive: boolean;
}

class SecretConverter {
  private sensitivePatterns = [
    /password/i,
    /secret/i,
    /key/i,
    /token/i,
    /credential/i,
    /api[_-]?key/i
  ];

  parseEnvFile(filePath: string): EnvSecret[] {
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n');
    const secrets: EnvSecret[] = [];

    for (const line of lines) {
      // Skip comments and empty lines
      if (line.trim().startsWith('#') || !line.trim()) {
        continue;
      }

      const [key, ...valueParts] = line.split('=');
      const value = valueParts.join('=').trim();

      if (key && value) {
        secrets.push({
          key: key.trim(),
          value: value.replace(/^["']|["']$/g, ''), // Remove quotes
          sensitive: this.isSensitive(key)
        });
      }
    }

    return secrets;
  }

  private isSensitive(key: string): boolean {
    return this.sensitivePatterns.some(pattern => pattern.test(key));
  }

  generateKubernetesSecret(
    name: string,
    namespace: string,
    secrets: EnvSecret[]
  ): string {
    const data: Record<string, string> = {};

    for (const secret of secrets) {
      // Base64 encode the value
      data[secret.key] = Buffer.from(secret.value).toString('base64');
    }

    const manifest = {
      apiVersion: 'v1',
      kind: 'Secret',
      metadata: {
        name,
        namespace,
        labels: {
          app: name,
          'managed-by': 'secret-converter'
        }
      },
      type: 'Opaque',
      data
    };

    return yaml.dump(manifest);
  }

  generateSealedSecret(
    secretManifest: string,
    publicKey: string
  ): string {
    // Use kubeseal to encrypt the secret
    // This would call the kubeseal CLI or library
    const sealed = execSync(
      `echo '${secretManifest}' | kubeseal --cert ${publicKey} --format yaml`,
      { encoding: 'utf-8' }
    );

    return sealed;
  }
}
```

## Secret Manifest Templates

### Basic Opaque Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{APP_NAME}}-secrets
  namespace: {{NAMESPACE}}
  labels:
    app: {{APP_NAME}}
type: Opaque
data:
  # Database credentials
  DB_HOST: {{BASE64_DB_HOST}}
  DB_PORT: {{BASE64_DB_PORT}}
  DB_USER: {{BASE64_DB_USER}}
  DB_PASSWORD: {{BASE64_DB_PASSWORD}}
  DB_NAME: {{BASE64_DB_NAME}}

  # API keys
  COHERE_API_KEY: {{BASE64_COHERE_API_KEY}}
  JWT_SECRET: {{BASE64_JWT_SECRET}}

  # External services
  REDIS_URL: {{BASE64_REDIS_URL}}
```

### Sealed Secret (Encrypted)

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: {{APP_NAME}}-secrets
  namespace: {{NAMESPACE}}
spec:
  encryptedData:
    DB_PASSWORD: AgBx8F2v3k...  # Encrypted with public key
    COHERE_API_KEY: AgCy9G3w4l...
    JWT_SECRET: AgDz0H4x5m...
  template:
    metadata:
      name: {{APP_NAME}}-secrets
      namespace: {{NAMESPACE}}
    type: Opaque
```

### External Secrets (AWS Secrets Manager)

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{APP_NAME}}-secrets
  namespace: {{NAMESPACE}}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: {{APP_NAME}}-secrets
    creationPolicy: Owner
  data:
    - secretKey: DB_PASSWORD
      remoteRef:
        key: prod/todo-app/db-password
    - secretKey: COHERE_API_KEY
      remoteRef:
        key: prod/todo-app/cohere-api-key
```

## Secret Usage in Pods

```yaml
# Environment variables from secret
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{APP_NAME}}
spec:
  template:
    spec:
      containers:
      - name: {{APP_NAME}}
        image: {{IMAGE}}
        env:
        # Individual secret values
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{APP_NAME}}-secrets
              key: DB_PASSWORD
        - name: COHERE_API_KEY
          valueFrom:
            secretKeyRef:
              name: {{APP_NAME}}-secrets
              key: COHERE_API_KEY

        # All secrets as environment variables
        envFrom:
        - secretRef:
            name: {{APP_NAME}}-secrets

        # Mount secrets as files
        volumeMounts:
        - name: secrets
          mountPath: /etc/secrets
          readOnly: true

      volumes:
      - name: secrets
        secret:
          secretName: {{APP_NAME}}-secrets
          defaultMode: 0400  # Read-only for owner
```

## RBAC for Secret Access

```yaml
# Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{APP_NAME}}-sa
  namespace: {{NAMESPACE}}

---
# Role - allows reading specific secrets
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{APP_NAME}}-secret-reader
  namespace: {{NAMESPACE}}
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["{{APP_NAME}}-secrets"]
  verbs: ["get"]

---
# RoleBinding - binds role to service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{APP_NAME}}-secret-reader-binding
  namespace: {{NAMESPACE}}
subjects:
- kind: ServiceAccount
  name: {{APP_NAME}}-sa
  namespace: {{NAMESPACE}}
roleRef:
  kind: Role
  name: {{APP_NAME}}-secret-reader
  apiGroup: rbac.authorization.k8s.io
```

## Sealed Secrets Setup

```yaml
sealed_secrets:
  installation:
    method: "helm"
    command: |
      helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
      helm install sealed-secrets sealed-secrets/sealed-secrets \
        --namespace kube-system

  workflow:
    step_1_create_secret:
      description: "Create regular Kubernetes secret"
      command: |
        kubectl create secret generic app-secrets \
          --from-literal=DB_PASSWORD=secret123 \
          --dry-run=client -o yaml > secret.yaml

    step_2_seal_secret:
      description: "Encrypt secret with public key"
      command: |
        kubeseal --format yaml < secret.yaml > sealed-secret.yaml

    step_3_commit_sealed:
      description: "Safe to commit to git"
      note: "Sealed secret can be stored in version control"

    step_4_apply:
      description: "Apply sealed secret to cluster"
      command: |
        kubectl apply -f sealed-secret.yaml

    step_5_automatic_unseal:
      description: "Controller automatically unseals"
      note: "Creates regular secret in cluster"
```

## Secret Rotation Strategy

```yaml
rotation_policy:
  database_passwords:
    frequency: "90 days"
    method: "automated"
    steps:
      - "Generate new password"
      - "Update database user"
      - "Update Kubernetes secret"
      - "Rolling restart pods"
      - "Verify connectivity"
      - "Revoke old password"

  api_keys:
    frequency: "180 days"
    method: "manual"
    steps:
      - "Generate new API key in provider"
      - "Update Kubernetes secret"
      - "Rolling restart pods"
      - "Verify API calls work"
      - "Revoke old API key"

  tls_certificates:
    frequency: "365 days"
    method: "automated (cert-manager)"
    steps:
      - "cert-manager requests renewal"
      - "ACME challenge completed"
      - "New certificate issued"
      - "Secret automatically updated"
      - "Ingress reloads certificate"
```

## Security Best Practices

```yaml
best_practices:
  storage:
    - "Never commit secrets to git"
    - "Use sealed-secrets or external-secrets"
    - "Enable encryption at rest"
    - "Rotate secrets regularly"

  access:
    - "Use RBAC to restrict access"
    - "Apply least privilege principle"
    - "Use service accounts, not user accounts"
    - "Audit secret access"

  usage:
    - "Mount secrets as files, not env vars (when possible)"
    - "Set restrictive file permissions (0400)"
    - "Don't log secret values"
    - "Validate secrets on startup"

  monitoring:
    - "Alert on secret access failures"
    - "Track secret age"
    - "Monitor for secret exposure"
    - "Audit secret modifications"
```

## Secret Validation

```typescript
class SecretValidator {
  validateSecret(secret: any): ValidationResult {
    const errors: string[] = [];
    const warnings: string[] = [];

    // Check if secret is base64 encoded
    for (const [key, value] of Object.entries(secret.data)) {
      if (!this.isBase64(value as string)) {
        errors.push(`${key} is not base64 encoded`);
      }
    }

    // Check for common mistakes
    if (this.containsPlaintext(secret)) {
      errors.push('Secret contains plaintext values');
    }

    // Check secret size
    const size = this.calculateSize(secret);
    if (size > 1048576) { // 1MB
      warnings.push('Secret size exceeds 1MB');
    }

    // Check for sensitive keys in metadata
    if (this.hasSensitiveMetadata(secret)) {
      warnings.push('Sensitive data in metadata (should be in data field)');
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }

  private isBase64(str: string): boolean {
    try {
      return Buffer.from(str, 'base64').toString('base64') === str;
    } catch {
      return false;
    }
  }

  private containsPlaintext(secret: any): boolean {
    // Check if stringData field is used (plaintext)
    return !!secret.stringData;
  }

  private calculateSize(secret: any): number {
    return JSON.stringify(secret).length;
  }

  private hasSensitiveMetadata(secret: any): boolean {
    const metadata = JSON.stringify(secret.metadata).toLowerCase();
    return /password|secret|key|token/.test(metadata);
  }
}
```

## Validation Commands

```yaml
validation_commands:
  - command: "kubectl get secret {{SECRET_NAME}} -o yaml"
    description: "View secret (values are base64 encoded)"
    success_criteria: "Secret exists and is properly formatted"

  - command: "kubectl get secret {{SECRET_NAME}} -o jsonpath='{.data.DB_PASSWORD}' | base64 -d"
    description: "Decode specific secret value"
    success_criteria: "Value decoded successfully"

  - command: "kubectl describe secret {{SECRET_NAME}}"
    description: "View secret metadata (no values shown)"
    success_criteria: "Metadata displayed, values hidden"

  - command: "kubectl auth can-i get secret/{{SECRET_NAME}} --as=system:serviceaccount:{{NAMESPACE}}:{{SA_NAME}}"
    description: "Check if service account can access secret"
    success_criteria: "Returns 'yes' if authorized"
```

## Integration Points

- **Depends On**: Kubernetes cluster, encryption tools
- **Next Skill**: `rbac-configurator` (access control)
- **Outputs To**: Application pods, deployment manifests

## Performance Targets

- Secret creation: < 2 seconds
- Secret mounting: < 1 second
- Encryption/decryption: < 500ms
- Secret rotation: < 5 minutes (zero downtime)

---

**Status**: Production-Ready ✅
**Last Updated**: 2026-02-16
**Maintainer**: Cloud-Native AI DevOps System
