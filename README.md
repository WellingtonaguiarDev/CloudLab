# CloudLab

Portfolio de infraestrutura cloud completo com foco em AWS, usando Terraform, Kubernetes, Helm e práticas modernas de DevOps/Platform Engineering.

> 🚀 **Como rodar do zero:** siga o [RUNBOOK.md](./RUNBOOK.md) — passo a passo completo, do clone até a aplicação no ar. Documentação detalhada em [docs/](./docs/).

---

## Visão Geral

| Item | Detalhe |
|---|---|
| Owner | Wellington |
| Ambiente | production |
| Região AWS | us-east-1 (Norte da Virgínia) |
| Terraform AWS Provider | ~> 6.0 |
| Terraform TLS Provider | ~> 4.0 |
| State Backend | S3 (desabilitado) |

---

## Arquitetura

```
Internet
    │
    ▼
 [WAF v2]
    │
    ▼
 [ALB] ── HTTPS (ACM) ── Route53
    │
    ├── /api/*  ──► [EKS] backend  ──► [RDS MySQL]
    │                               ──► [ElastiCache Redis]
    │                               ──► [S3]
    │                               ──► [Secrets Manager]
    │
    └── /*      ──► [EKS] frontend
    
[ECS Fargate] ── workloads alternativos
[EFS]         ── storage compartilhado (EKS)
[ECR]         ── registry de imagens
[CloudWatch]  ── logs e alarmes
[KMS]         ── criptografia centralizada
```

---

## Stack de Tecnologias

| Camada | Tecnologia |
|---|---|
| IaC | Terraform ~> 6.0 |
| Containers | EKS 1.33 + ECS Fargate |
| Package Manager | Helm |
| CI/CD | GitHub Actions (OIDC) |
| Monitoring | Prometheus + Grafana (kube-prometheus-stack) |
| Service Mesh | AWS Load Balancer Controller |
| Storage | EBS gp3, EFS, S3 |
| Database | RDS MySQL 8.4 |
| Cache | ElastiCache Redis 7.1 |
| Security | WAF v2, KMS, Secrets Manager, Network Policies, PSS |

---

## Módulos Terraform

Todos os módulos ficam em `infrastructure/terraform/modules/` e são orquestrados via `infrastructure/terraform/live/cloudlab/modules.tf`.

| Módulo | Serviço AWS | Detalhe |
|---|---|---|
| `vpc` | Virtual Private Cloud | 3 AZs, subnets públicas/privadas, NAT Gateway, NACLs |
| `eks` | Elastic Kubernetes Service | v1.33, t3.medium, OIDC/IRSA |
| `ecs` | Elastic Container Service | Fargate, nginx, awsvpc |
| `rds` | Relational Database Service | MySQL 8.4, encrypted, subnet privada |
| `s3` | Simple Storage Service | SSE-S3, Block Public Access |
| `ecr` | Elastic Container Registry | IMMUTABLE tags, scan on push |
| `kms` | Key Management Service | 3 chaves (rds, s3, secrets), key rotation |
| `secrets-manager` | Secrets Manager | KMS encrypted, credenciais RDS |
| `iam` | Identity and Access Management | IRSA roles (backend, controllers) |
| `security-groups` | Security Groups | ALB, ElastiCache, EFS |
| `acm` | AWS Certificate Manager | DNS validation via Route53 |
| `route53` | Route 53 | Hosted zone, ALIAS records para ALB |
| `alb` | Application Load Balancer | HTTP→HTTPS redirect, TLS 1.3, target groups |
| `efs` | Elastic File System | KMS encrypted, mount targets 3 AZs |
| `elasticache` | ElastiCache | Redis 7.1, at-rest + in-transit encryption |
| `cloudwatch` | CloudWatch | Log groups, alarmes RDS/ECS/ALB, dashboard |
| `waf` | Web Application Firewall | CommonRuleSet, SQLi, KnownBadInputs, rate limit |

---

## Estrutura do Projeto

```
CloudLab/
├── applications/
│   ├── backend/
│   └── frontend/
├── cicd/
│   └── .github/
│       └── workflows/
│           ├── ci.yaml           # Build & Push ECR
│           ├── cd.yaml           # Deploy Helm no EKS
│           └── terraform.yaml    # Plan/Apply com aprovação
├── diagrams/
├── docs/
├── helm-charts/
│   ├── backend/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── _helpers.tpl
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── serviceaccount.yaml
│   │       ├── hpa.yaml
│   │       └── pdb.yaml
│   └── frontend/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── serviceaccount.yaml
│           ├── hpa.yaml
│           └── pdb.yaml
├── infrastructure/
│   ├── bootstrap/
│   └── terraform/
│       ├── live/
│       │   └── cloudlab/
│       │       ├── backend.tf
│       │       ├── locals.tf
│       │       ├── modules.tf
│       │       ├── outputs.tf
│       │       ├── providers.tf
│       │       ├── terraform.tfvars
│       │       ├── variables.tf
│       │       └── versions.tf
│       └── modules/
│           ├── acm/
│           ├── alb/
│           ├── cloudwatch/
│           ├── ecr/
│           ├── ecs/
│           ├── efs/
│           ├── eks/
│           ├── elasticache/
│           ├── iam/
│           ├── kms/
│           ├── rds/
│           ├── route53/
│           ├── s3/
│           ├── secrets-manager/
│           ├── security-groups/
│           ├── vpc/
│           └── waf/
├── kubernetes/
│   └── kube-system/
│       ├── aws-load-balancer-controller/
│       ├── aws-ebs-csi-driver/
│       ├── aws-efs-csi-driver/
│       ├── cluster-autoscaler/
│       └── metrics-server/
├── monitoring/
│   ├── prometheus/
│   │   ├── values.yaml           # kube-prometheus-stack
│   │   ├── servicemonitor.yaml
│   │   └── alerts.yaml           # PrometheusRule customizado
│   └── grafana/
│       └── dashboards/
│           └── cloudlab.yaml     # Dashboard da aplicação
├── runbooks/
│   ├── deploy.md
│   ├── troubleshooting-pods.md
│   ├── incident-response.md
│   └── infrastructure.md
├── security/
│   ├── network-policies/
│   │   ├── app.yaml
│   │   └── monitoring.yaml
│   ├── pod-security/
│   │   └── namespaces.yaml
│   ├── rbac/
│   │   └── roles.yaml
│   └── checklist.md
├── tests/
├── tools/
└── README.md
```

---

## Módulo VPC

| Atributo | Valor |
|---|---|
| VPC Name | `PROD-cloudlab-VPC` |
| CIDR Block | `172.22.0.0/16` |
| DNS Support | ✅ |
| DNS Hostnames | ✅ |
| Internet Gateway | ✅ |
| NAT Gateway | 1x (EIP dedicado, subnet pública A) |
| NACLs | Public + Private |

### Subnets

| Nome | CIDR | AZ | Tipo |
|---|---|---|---|
| PROD-Subnet-Public-A | `172.22.0.0/20` | us-east-1a | Pública |
| PROD-Subnet-Public-B | `172.22.16.0/20` | us-east-1b | Pública |
| PROD-Subnet-Public-C | `172.22.32.0/20` | us-east-1c | Pública |
| PROD-Subnet-Private-A | `172.22.64.0/19` | us-east-1a | Privada |
| PROD-Subnet-Private-B | `172.22.96.0/19` | us-east-1b | Privada |
| PROD-Subnet-Private-C | `172.22.128.0/19` | us-east-1c | Privada |

---

## Módulo EKS

| Atributo | Valor |
|---|---|
| Cluster Name | `cloudlab-eks` |
| Kubernetes Version | `1.33` |
| Subnets | Privadas da VPC |
| Node Group | `cloudlab-eks-default` |
| Instance Types | `t3.medium` |
| Desired Size | 2 |
| Min Size | 2 |
| Max Size | 4 |
| OIDC Provider | ✅ (para IRSA) |
| Cluster IAM Role | `cloudlab-eks-cluster-role` |
| Node IAM Role | `cloudlab-eks-nodegroup-role` |

### Controllers (kube-system)

| Controller | Função |
|---|---|
| AWS Load Balancer Controller | Provisiona ALB/NLB via Ingress |
| AWS EBS CSI Driver | StorageClass `gp3` encrypted (default) |
| AWS EFS CSI Driver | StorageClass `efs-sc` com access point |
| Cluster Autoscaler | Escala node groups automaticamente |
| Metrics Server | Habilita HPA e `kubectl top` |

---

## Módulo ECS

| Atributo | Valor |
|---|---|
| Cluster Name | `cloudlab-ecs` |
| Launch Type | Fargate |
| Service Name | `nginx` |
| Container Port | 80 |
| CPU | 256 |
| Memory | 512 MB |
| Network Mode | awsvpc |
| Subnets | Privadas da VPC |

---

## Módulo RDS

| Atributo | Valor |
|---|---|
| Identifier | `cloudlab-mysql` |
| Engine | MySQL 8.4 |
| Instance Class | `db.t3.micro` |
| Storage | 20 GB (autoscaling até 100 GB) |
| Multi-AZ | ❌ |
| Backup Retention | 7 dias |
| Storage Encrypted | ✅ |
| Publicly Accessible | ❌ |
| Parameter Group | `mysql8.4` (utf8mb4) |
| Credenciais | Secrets Manager (`cloudlab/rds`) |

---

## Módulo KMS

| Chave | Alias | Uso |
|---|---|---|
| cloudlab-kms-rds | `alias/cloudlab-rds` | Criptografia RDS |
| cloudlab-kms-s3 | `alias/cloudlab-s3` | Criptografia S3 / EFS / ElastiCache |
| cloudlab-kms-secrets | `alias/cloudlab-secrets` | Criptografia Secrets Manager |

---

## Helm Charts

### Backend

| Atributo | Valor |
|---|---|
| Namespace | `app` |
| Replicas | 2 (HPA: 2–6) |
| CPU Request/Limit | 100m / 500m |
| Memory Request/Limit | 128Mi / 512Mi |
| Service Port | 8080 |
| Health Check | `GET /health` |
| IRSA | ✅ (S3 + Secrets Manager) |
| PDB | minAvailable: 1 |
| TopologySpread | 3 AZs |

### Frontend

| Atributo | Valor |
|---|---|
| Namespace | `app` |
| Replicas | 2 (HPA: 2–4) |
| CPU Request/Limit | 50m / 200m |
| Memory Request/Limit | 64Mi / 256Mi |
| Service Port | 80 |
| PDB | minAvailable: 1 |
| TopologySpread | 3 AZs |

---

## CI/CD

| Workflow | Trigger | Ação |
|---|---|---|
| `ci.yaml` | Push/PR em `main` (applications/) | Build + Push ECR com SHA tag |
| `cd.yaml` | CI com sucesso em `main` | Helm upgrade + rollout verify |
| `terraform.yaml` | Push/PR em `main` (infrastructure/) | Plan no PR, Apply com aprovação |

- Autenticação AWS via **OIDC** → zero `AWS_ACCESS_KEY_ID`
- Terraform Apply requer aprovação manual via `environment: production`
- Helm com `--atomic` → rollback automático em falha

---

## Monitoring

| Componente | Detalhe |
|---|---|
| Prometheus | Retenção 15d / 10GB, PVC gp3 |
| Grafana | Dashboard CloudLab (Request Rate, Error Rate, Latency p99, CPU, Memory) |
| Alertmanager | Roteamento configurado |
| Node Exporter | Métricas de nodes |
| Kube State Metrics | Métricas de objetos Kubernetes |

### Alertas

| Alerta | Condição | Severidade |
|---|---|---|
| BackendHighErrorRate | 5xx > 5% por 5min | Critical |
| BackendHighLatency | p99 > 2s por 5min | Warning |
| PodCrashLooping | > 3 restarts em 15min | Critical |
| PodNotReady | Pod não ready por 5min | Warning |
| RDS CPU High | CPU > 80% | Warning |
| RDS Storage Low | Storage livre < 5GB | Warning |
| ECS CPU High | CPU > 80% | Warning |
| ALB 5xx High | Erros 5xx > 10 | Warning |

---

## Security

| Controle | Detalhe |
|---|---|
| NetworkPolicy | default-deny-all + allow seletivo por porta/seletor |
| Pod Security Standards | `restricted` (app), `baseline` (monitoring) |
| RBAC | Roles `developer`, `readonly`, `monitoring-viewer` |
| IRSA | Todos os workloads e controllers usam IRSA |
| WAF | CommonRuleSet + SQLi + KnownBadInputs + rate limit 2000 req/5min |
| KMS | Key rotation automática em todas as chaves |
| Secrets | Zero credenciais em código — tudo via Secrets Manager |
| TLS | ALB com TLS 1.3, redirect HTTP→HTTPS |
| ECR | Tag immutability + scan on push |

---

## Runbooks

| Runbook | Conteúdo |
|---|---|
| `deploy.md` | Fluxo CI/CD, deploy manual, rollback |
| `troubleshooting-pods.md` | CrashLoop, Pending, health check, conectividade |
| `incident-response.md` | Resposta a cada alerta do Prometheus |
| `infrastructure.md` | Terraform, kubeconfig, helm installs, Grafana |

---

## Status

> ✅ Portfolio completo
