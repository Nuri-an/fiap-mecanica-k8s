# FiapMecanica Kubernetes Configuration - Documentação Completa

## 📋 Índice
1. [Descrição](#descrição)
2. [Tecnologias](#tecnologias)
3. [Arquitetura](#arquitetura)
4. [Setup e Instalação](#setup-e-instalação)
5. [Deploy](#deploy)
6. [Operações](#operações)
7. [Troubleshooting](#troubleshooting)
8. [Estrutura do Projeto](#estrutura-do-projeto)

---

## 🎯 Descrição

### Propósito Geral
**FiapMecanica Kubernetes** contém toda a configuração de infraestrutura para deploy da aplicação em AWS EKS. Responsável por:

- **Orquestração de Containers**: Deployment de pods, replicação, auto-healing
- **Load Balancing**: ALB Ingress para distribuição de tráfego
- **Service Discovery**: Comunicação entre serviços
- **Resource Management**: CPU/memoria limits e requests
- **Configuration**: ConfigMaps e Secrets
- **Observabilidade**: Pod monitoring, log collection

### Ambientes
1. **Base**: Configuração comum reutilizável
2. **Production**: Overlay com 3 réplicas, resource limits, health checks
3. **Staging**: Overlay com 1 réplica, menos recursos

### Diferencial
- ✓ **Kustomize**: Composição modular de manifests
- ✓ **GitOps Ready**: Gerenciamento via git
- ✓ **High Availability**: 3 réplicas em múltiplas AZs
- ✓ **Auto-Healing**: Restart automático de pods falhando
- ✓ **Resource Limits**: Proteção contra consumo excessivo
- ✓ **Security**: Network policies, RBAC, least privilege

---

## 🛠️ Tecnologias

### Kubernetes
| Componente | Versão | Propósito |
|-----------|--------|----------|
| **Kubernetes** | 1.30 | Container orchestration |
| **EKS** | Managed | AWS Kubernetes service |
| **Kustomize** | 5.x | Configuration management |
| **kubectl** | 1.30 | CLI tool |

### Networking
| Componente | Versão | Propósito |
|-----------|--------|----------|
| **ALB Ingress Controller** | 2.6.x | Load balancer integration |
| **CoreDNS** | Included | Service discovery |
| **Calico** | Included | Network policies |

### Storage & Config
| Componente | Propósito |
|-----------|----------|
| **ConfigMap** | Non-sensitive configuration |
| **Secrets** | Sensitive data (encrypted at rest) |
| **Persistent Volumes** | (Não usado, stateless app) |

### Monitoring
| Componente | Propósito |
|-----------|----------|
| **Prometheus** | (Opcional) Metrics collection |
| **CloudWatch** | AWS native monitoring |
| **Datadog** | APM & logs aggregation |

---

## 🏗️ Arquitetura

### Visão Geral de Cluster

```
┌─────────────────────────────────────────────────────────┐
│                  AWS EKS Cluster                        │
│            fiap-mecanica-prod                           │
│            Region: us-east-1                            │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │          Kubernetes Control Plane (Managed)        │ │
│  │  ├─ API Server                                     │ │
│  │  ├─ etcd                                           │ │
│  │  ├─ Scheduler                                      │ │
│  │  └─ Controller Manager                             │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │          Managed Node Group                         │ │
│  │  (3 nodes em diferentes AZs)                       │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │ Node 1 (us-east-1a)                          │  │ │
│  │  │ ┌────────────────────────────────────────────┤  │ │
│  │  │ │ Pod: fiap-mecanica-api-xyz123-abc1        │  │ │
│  │  │ │ ├─ Container: nginx (sidecar)             │  │ │
│  │  │ │ └─ Container: nestjs-app                  │  │ │
│  │  │ ├─ Requests: CPU 100m, Memory 256Mi         │  │ │
│  │  │ └─ Limits: CPU 500m, Memory 512Mi           │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │ Node 2 (us-east-1b)                          │  │ │
│  │  │ └─ Pod: fiap-mecanica-api-xyz123-def2       │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │ Node 3 (us-east-1c)                          │  │ │
│  │  │ └─ Pod: fiap-mecanica-api-xyz123-ghi3       │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │ System Pods (kube-system)                    │  │ │
│  │  │ ├─ aws-node (networking)                    │  │ │
│  │  │ ├─ kube-proxy                               │  │ │
│  │  │ ├─ coredns                                  │  │ │
│  │  │ ├─ calico-node                              │  │ │
│  │  │ └─ ebs-csi-driver                           │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │                                                     │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │ Datadog/Monitoring Pods (optional)           │  │ │
│  │  │ ├─ datadog-agent                            │  │ │
│  │  │ └─ datadog-cluster-agent                    │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │          Kubernetes Services                        │ │
│  │  ├─ Service: fiap-mecanica-service               │ │
│  │  │  └─ Type: ClusterIP                           │ │
│  │  │  └─ Port: 80                                  │ │
│  │  └─ Ingress: fiap-mecanica-ingress              │ │
│  │     └─ Class: alb                               │ │
│  │     └─ Host: ALB (AWS-managed)                  │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
           │
           │ (External traffic)
           │
┌──────────▼──────────────────────────┐
│ AWS Application Load Balancer (ALB) │
│ k8s-fiapmeca-fiapmeca-45c90263bc   │
│ us-east-1.elb.amazonaws.com         │
│                                      │
│ HTTP (80) → Ingress                 │
│ Health check: /api/v1/health        │
└─────────────────────────────────────┘
           │
           ├─────────────────────────┐
           │                         │
    ┌──────▼──────┐        ┌─────────▼────┐
    │ AWS RDS     │        │ AWS Secrets  │
    │ PostgreSQL  │        │ Manager      │
    └─────────────┘        └──────────────┘
```

### Estrutura de Namespaces

```
Cluster
├── kube-system (sistema Kubernetes)
│   ├─ CoreDNS
│   ├─ Calico
│   ├─ AWS VPC CNI
│   └─ EBS CSI Driver
│
├── kube-public
│   └─ (public ConfigMaps)
│
├── fiap-mecanica (aplicação)
│   ├─ Deployment: fiap-mecanica-api
│   │  ├─ Pod 1 (Replica)
│   │  ├─ Pod 2 (Replica)
│   │  └─ Pod 3 (Replica)
│   │
│   ├─ Service: fiap-mecanica-service
│   │  ├─ Type: ClusterIP
│   │  └─ Selector: app=fiap-mecanica-api
│   │
│   ├─ Ingress: fiap-mecanica-ingress
│   │  └─ Class: alb
│   │
│   ├─ ConfigMap: app-config
│   │  └─ Non-sensitive vars
│   │
│   └─ Secret: app-secrets
│       └─ Sensitive data (encrypted)
│
└── datadog (optional)
    └─ Datadog Agent
```

### Fluxo de Requisição

```
1. Client Request
   │
   └─→ ALB (AWS managed)
       ├─ DNS resolution: k8s-fiapmeca-...elb.amazonaws.com
       ├─ HTTP health check: /api/v1/health
       └─ Target groups: nodes in the cluster
           │
           └─→ Ingress Controller (ALB Controller)
               ├─ Reads: Ingress resource
               ├─ Creates/Updates: ALB rules
               └─ Routes traffic to Service
                   │
                   └─→ Service (fiap-mecanica-service)
                       ├─ Type: ClusterIP
                       ├─ Selector: app=fiap-mecanica-api
                       ├─ Port: 80 (external) → 3000 (internal)
                       └─ Routes to Pods (round-robin)
                           │
                           └─→ Pod Replica 1
                           └─→ Pod Replica 2
                           └─→ Pod Replica 3
                               ├─ NestJS app listening on :3000
                               ├─ Requests to PostgreSQL (VPC)
                               └─ Traces to Datadog
```

---

## 📦 Setup e Instalação

### Pré-Requisitos

```bash
# Ferramentas necessárias
kubectl >= 1.27.0
kustomize >= 5.0.0
aws-cli >= 2.0.0
curl
jq

# Permissões AWS
- EKS admin access
- ECR read access
- RDS access
- ALB controller permissions
```

### Step 1: Configurar kubectl

```bash
# Atualizar kubeconfig
$ aws eks update-kubeconfig \
  --name fiap-mecanica-prod \
  --region us-east-1

# Verificar conexão
$ kubectl cluster-info
$ kubectl get nodes

# Esperado:
# NAME                          STATUS   ROLES
# ip-10-0-1-123.ec2.internal   Ready    <none>
# ip-10-0-2-456.ec2.internal   Ready    <none>
# ip-10-0-3-789.ec2.internal   Ready    <none>
```

### Step 2: Clonar Repositório

```bash
$ git clone https://github.com/Nuri-an/fiap-mecanica-k8s.git
$ cd fiap-mecanica-k8s
$ git checkout main
```

### Step 3: Preparar Secrets

```bash
# Obter JWT Secret do Secrets Manager
$ aws secretsmanager get-secret-value \
  --secret-id "fiap-mecanica/prod/jwt-secret" \
  --region us-east-1 \
  --query 'SecretString' \
  --output text > /tmp/jwt-secret.txt

# Obter Database URL
$ aws secretsmanager get-secret-value \
  --secret-id "fiap-mecanica/prod/database-url" \
  --region us-east-1 \
  --query 'SecretString' \
  --output text > /tmp/database-url.txt

# Criar Kubernetes Secret
$ kubectl create secret generic app-secrets \
  --from-file=JWT_SECRET=/tmp/jwt-secret.txt \
  --from-file=DATABASE_URL=/tmp/database-url.txt \
  -n fiap-mecanica \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Step 4: Deploy

```bash
# Deploy usando Kustomize (veja Step abaixo)
# Ou continuar para próxima seção
```

---

## 🚀 Deploy

### Deploy com Kustomize

```bash
# Aplicar manifests (base + overlays)
$ kubectl apply -k k8s/overlays/production/

# Ou especificar namespace
$ kubectl apply -k k8s/overlays/production/ -n fiap-mecanica

# Esperado output:
# namespace/fiap-mecanica created
# deployment.apps/fiap-mecanica-api created
# service/fiap-mecanica-service created
# ingress.networking.k8s.io/fiap-mecanica-ingress created
# configmap/app-config created
# secret/app-secrets created
```

### Verificar Deploy

```bash
# Verificar Deployment
$ kubectl get deployment -n fiap-mecanica
# NAME                   READY   UP-TO-DATE   AVAILABLE
# fiap-mecanica-api      3/3     3            3

# Verificar Pods
$ kubectl get pods -n fiap-mecanica -o wide
# NAME                               READY   STATUS    NODE
# fiap-mecanica-api-xyz123-abc1     1/1     Running   ip-10-0-1-123...
# fiap-mecanica-api-xyz123-def2     1/1     Running   ip-10-0-2-456...
# fiap-mecanica-api-xyz123-ghi3     1/1     Running   ip-10-0-3-789...

# Verificar Service
$ kubectl get svc -n fiap-mecanica
# NAME                      TYPE        CLUSTER-IP      PORT(S)
# fiap-mecanica-service     ClusterIP   172.20.123.45   80/TCP

# Verificar Ingress
$ kubectl get ingress -n fiap-mecanica
# NAME                    CLASS   HOSTS   ADDRESS
# fiap-mecanica-ingress   alb     *       k8s-fiapmeca...
```

### Acessar Aplicação

```bash
# Obter URL do ALB
$ ALB_URL=$(kubectl get ingress -n fiap-mecanica \
  fiap-mecanica-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "API URL: http://$ALB_URL/api/v1"

# Health check
$ curl http://$ALB_URL/api/v1/health
# {"status":"ok"}

# Swagger docs
$ open http://$ALB_URL/api/docs
```

### Rollout & Atualizações

```bash
# Ver histórico de rollouts
$ kubectl rollout history deployment/fiap-mecanica-api \
  -n fiap-mecanica

# Rollout status
$ kubectl rollout status deployment/fiap-mecanica-api \
  -n fiap-mecanica

# Fazer rollback se necessário
$ kubectl rollout undo deployment/fiap-mecanica-api \
  -n fiap-mecanica

# Forçar nova versão (atualizar imagem)
$ kubectl set image deployment/fiap-mecanica-api \
  fiap-mecanica-api=941377151341.dkr.ecr.us-east-1.amazonaws.com/fiap-mecanica-api:latest \
  -n fiap-mecanica --record
```

---

## 🔧 Operações

### Ver Logs

```bash
# Logs de um pod específico
$ kubectl logs -n fiap-mecanica \
  fiap-mecanica-api-xyz123-abc1

# Logs em tempo real (follow)
$ kubectl logs -n fiap-mecanica \
  fiap-mecanica-api-xyz123-abc1 \
  -f

# Logs de todos os pods do deployment
$ kubectl logs -n fiap-mecanica \
  -l app=fiap-mecanica-api \
  --all-containers=true \
  -f

# Últimas 50 linhas
$ kubectl logs -n fiap-mecanica \
  fiap-mecanica-api-xyz123-abc1 \
  --tail=50
```

### Acessar Pod (Debug)

```bash
# Executar comando no pod
$ kubectl exec -n fiap-mecanica \
  fiap-mecanica-api-xyz123-abc1 \
  -- curl localhost:3000/api/v1/health

# Abrir terminal (bash) no pod
$ kubectl exec -it -n fiap-mecanica \
  fiap-mecanica-api-xyz123-abc1 \
  -- /bin/sh

# Dentro do pod, testar conectividade
$ curl http://fiap-mecanica-service:80/api/v1/health
$ nc -zv <RDS_ENDPOINT> 5432
```

### Descrever Recursos

```bash
# Detalhes de um pod
$ kubectl describe pod -n fiap-mecanica \
  fiap-mecanica-api-xyz123-abc1

# Detalhes do deployment
$ kubectl describe deployment -n fiap-mecanica \
  fiap-mecanica-api

# Detalhes do ingress
$ kubectl describe ingress -n fiap-mecanica \
  fiap-mecanica-ingress
```

### Editar Resources

```bash
# Editar deployment YAML
$ kubectl edit deployment -n fiap-mecanica \
  fiap-mecanica-api

# Editar ConfigMap
$ kubectl edit configmap -n fiap-mecanica \
  app-config

# Editar Secret (cuidado!)
$ kubectl edit secret -n fiap-mecanica \
  app-secrets
```

### Scaling

```bash
# Aumentar réplicas
$ kubectl scale deployment fiap-mecanica-api \
  -n fiap-mecanica \
  --replicas=5

# Verificar
$ kubectl get deployment -n fiap-mecanica \
# fiap-mecanica-api      5/5     5            5

# Reduzir
$ kubectl scale deployment fiap-mecanica-api \
  -n fiap-mecanica \
  --replicas=3
```

### Resource Usage

```bash
# Uso de CPU e memória dos pods
$ kubectl top pods -n fiap-mecanica

# Uso dos nodes
$ kubectl top nodes

# Monitorar em tempo real
$ watch kubectl top pods -n fiap-mecanica
```

---

## 🐛 Troubleshooting

### Pod não inicia (ImagePullBackOff)

```bash
# Verificar eventos
$ kubectl describe pod -n fiap-mecanica <POD_NAME>
# Procurar por "ImagePullBackOff" ou "ErrImagePull"

# Verificar imagem existe no ECR
$ aws ecr describe-images \
  --repository-name fiap-mecanica-api \
  --region us-east-1

# Verificar credenciais ECR
$ kubectl get secrets -n fiap-mecanica | grep ecr

# Se falta credencial, criar:
$ kubectl create secret docker-registry ecr-secret \
  --docker-server=941377151341.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  -n fiap-mecanica
```

### Pod crashes (CrashLoopBackOff)

```bash
# Ver logs de erro
$ kubectl logs -n fiap-mecanica <POD_NAME> --previous

# Causas comuns:
# - Banco de dados inacessível
# - Secret/ConfigMap não encontrados
# - Port já em uso
# - Application crashed

# Verificar eventos
$ kubectl describe pod -n fiap-mecanica <POD_NAME> | grep -A 5 Events
```

### Conexão com banco recusada

```bash
# Testar conectividade do pod ao RDS
$ kubectl exec -n fiap-mecanica <POD_NAME> -- \
  nc -zv <RDS_ENDPOINT> 5432

# Se falhar, verificar:
# 1. Security groups do RDS e Lambda
$ aws ec2 describe-security-groups \
  --filter "Name=group-id,Values=sg-0059a2b369f07941d" \
  --region us-east-1

# 2. Variável DATABASE_URL
$ kubectl get secret -n fiap-mecanica app-secrets \
  -o jsonpath='{.data.DATABASE_URL}' | base64 -d

# 3. VPC routing
$ kubectl exec -n fiap-mecanica <POD_NAME> -- \
  traceroute <RDS_ENDPOINT>
```

### Ingress não redireciona tráfego

```bash
# Verificar Ingress status
$ kubectl describe ingress -n fiap-mecanica \
  fiap-mecanica-ingress

# Procurar por:
# Status: "Active"
# Address: URL do ALB

# Se não tem address, ALB pode estar em pendente
# Esperar 2-3 minutos

# Verificar ALB Controller logs
$ kubectl logs -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller \
  -f
```

### Métricas não aparecem no Datadog

```bash
# Verificar pod do Datadog Agent
$ kubectl get pods -n datadog

# Logs do agent
$ kubectl logs -n datadog -l app=datadog-agent | tail -50

# Se agent não existe, instalar:
$ helm install datadog datadog/datadog \
  -n datadog \
  --create-namespace \
  -f values.yaml
```

---

## 📁 Estrutura do Projeto

```
fiap-mecanica-k8s/
├── k8s/
│   ├── base/                            # Configuração base (reutilizável)
│   │   ├── deployment.yaml              # Deployment definition
│   │   │   ├─ Replicas: 3
│   │   │   ├─ Resources (requests/limits)
│   │   │   ├─ Health checks (liveness/readiness)
│   │   │   ├─ Environment variables
│   │   │   └─ Volume mounts
│   │   │
│   │   ├── service.yaml                 # Service ClusterIP
│   │   │   ├─ Type: ClusterIP
│   │   │   ├─ Port: 80 → 3000
│   │   │   └─ Selector: app=fiap-mecanica-api
│   │   │
│   │   ├── configmap.yaml               # Non-sensitive configuration
│   │   │   ├─ NODE_ENV=production
│   │   │   ├─ API_PREFIX=api/v1
│   │   │   └─ LOG_LEVEL=info
│   │   │
│   │   ├── secret.yaml                  # Sensitive data template
│   │   │   └─ (Preenchido com valores reais durante deploy)
│   │   │
│   │   ├── namespace.yaml               # Kubernetes namespace
│   │   │   └─ name: fiap-mecanica
│   │   │
│   │   └── kustomization.yaml           # Kustomize config
│   │       ├─ resources:
│   │       │   ├─ namespace.yaml
│   │       │   ├─ deployment.yaml
│   │       │   ├─ service.yaml
│   │       │   ├─ configmap.yaml
│   │       │   └─ secret.yaml
│   │       ├─ namePrefix: (none)
│   │       └─ labels:
│   │           └─ app: fiap-mecanica
│   │
│   └── overlays/                        # Environment-specific customizations
│       ├── production/                  # Production environment
│       │   ├── ingress.yaml             # ALB Ingress definition
│       │   │   ├─ Class: alb
│       │   │   ├─ Health path: /api/v1/health
│       │   │   ├─ Scheme: internet-facing
│       │   │   ├─ Subnets: prod subnets
│       │   │   └─ Security groups: prod SGs
│       │   │
│       │   ├── kustomization.yaml       # Kustomize overlay
│       │   │   ├─ bases:
│       │   │   │   └─ ../../base
│       │   │   ├─ replicas: 3
│       │   │   ├─ resources:
│       │   │   │   └─ ingress.yaml
│       │   │   └─ patches:
│       │   │       ├─ cpu limit: 500m
│       │   │       ├─ memory limit: 512Mi
│       │   │       └─ node selector
│       │   │
│       │   └── patches.yaml             # Resource customizations
│       │       ├─ Resource limits
│       │       ├─ Replica count
│       │       └─ Node affinity
│       │
│       └── staging/                     # Staging environment
│           ├── kustomization.yaml
│           └── patches.yaml
│
├── docs/                                # Documentation
│   ├── deployment-guide.md
│   ├── troubleshooting.md
│   ├── monitoring.md
│   └── scaling.md
│
├── scripts/                             # Helper scripts
│   ├── deploy.sh                        # Deploy script
│   ├── cleanup.sh                       # Cleanup script
│   ├── health-check.sh                  # Verify deployment
│   └── get-alb-url.sh                   # Get ALB endpoint
│
└── README.md
```

---

## 📊 Configurações Detalhadas

### Deployment Spec

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fiap-mecanica-api
  namespace: fiap-mecanica
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fiap-mecanica-api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Zero downtime deployment
  template:
    metadata:
      labels:
        app: fiap-mecanica-api
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - fiap-mecanica-api
              topologyKey: kubernetes.io/hostname
      containers:
      - name: fiap-mecanica-api
        image: 941377151341.dkr.ecr.us-east-1.amazonaws.com/fiap-mecanica-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
          protocol: TCP
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: NODE_ENV
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: JWT_SECRET
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_URL
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /api/v1/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /api/v1/health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
```

---

## 🔐 Segurança

✓ Network policies (restrito por padrão)  
✓ RBAC (least privilege roles)  
✓ Secrets encryption at rest  
✓ Pod security policies  
✓ Non-root containers  
✓ Read-only root filesystem  
✓ Resource limits (DoS prevention)  
✓ Health checks (auto-healing)  

---

## 📞 Suporte

**Documentação Adicional**:
- [Deploy Guide](./docs/deployment-guide.md)
- [Troubleshooting](./docs/troubleshooting.md)
- [Monitoring](./docs/monitoring.md)

**GitHub Issues**:
- https://github.com/Nuri-an/fiap-mecanica-k8s/issues

---

**Última Atualização**: 26 de maio de 2026  
**Status**: Production Ready  
**Versão**: 1.0
