# CloudLab

Portfolio de infraestrutura cloud em andamento, com foco em AWS usando Terraform, Kubernetes, Helm e práticas modernas de DevOps/Platform Engineering.

---

## Visão Geral

| Item | Detalhe |
|---|---|
| Owner | Wellington |
| Ambiente | production |
| Região AWS | us-east-1 (Norte da Virgínia) |
| Cluster EKS | cloudlab-prod |
| Terraform AWS Provider | ~> 6.0 |
| State Backend | S3 |

---

## Módulos Terraform

Todos os módulos ficam em `infrastructure/terraform/modules/` e são orquestrados via `infrastructure/terraform/live/cloudlab/modules.tf`.

| Módulo | Serviço AWS |
|---|---|
| `acm` | AWS Certificate Manager |
| `alb` | Application Load Balancer |
| `cloudwatch` | CloudWatch (logs e métricas) |
| `ecr` | Elastic Container Registry |
| `efs` | Elastic File System |
| `eks` | Elastic Kubernetes Service |
| `elasticache` | ElastiCache (Redis/Memcached) |
| `iam` | Identity and Access Management |
| `kms` | Key Management Service |
| `rds` | Relational Database Service |
| `route53` | Route 53 (DNS) |
| `s3` | Simple Storage Service |
| `security-groups` | Security Groups (VPC) |
| `secrets-manager` | Secrets Manager |
| `vpc` | Virtual Private Cloud |
| `waf` | Web Application Firewall |

---

## Estrutura do Projeto

```
CloudLab/
├── applications/
│   ├── backend/
│   └── frontend/
├── cicd/
├── diagrams/
├── docs/
├── helm-charts/
├── infrastructure/
│   ├── bootstrap/
│   └── terraform/
│       ├── live/
│       │   └── cloudlab/
│       │       ├── backend.tf        # Remote state no S3
│       │       ├── locals.tf         # Tags padrão (Environment, Project, Owner)
│       │       ├── modules.tf        # Orquestração de todos os módulos
│       │       ├── outputs.tf
│       │       ├── providers.tf      # Provider AWS (região via variável)
│       │       ├── terraform.tfvars  # us-east-1 / production / cloudlab-prod
│       │       ├── variables.tf      # region, environment, cluster_name
│       │       └── versions.tf       # AWS provider ~> 6.0
│       └── modules/
│           ├── acm/
│           ├── alb/
│           ├── cloudwatch/
│           ├── ecr/
│           ├── efs/
│           ├── eks/
│           ├── elasticache/
│           ├── iam/
│           ├── kms/
│           ├── rds/
│           ├── route53/
│           ├── s3/
│           ├── security-groups/
│           ├── secrets-manager/
│           ├── vpc/
│           │   ├── _locals.tf
│           │   ├── _variables.tf
│           │   ├── acls.tf
│           │   ├── eip_natgateway.tf
│           │   ├── internet_gateway.tf
│           │   ├── route_tables.tf
│           │   ├── subnets.tf
│           │   └── vpc.tf
│           └── waf/
├── kubernetes/
├── monitoring/
├── plataform/
├── portfolio/
├── runbooks/
├── security/
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

### Route Tables

| Tabela | Destino | Target |
|---|---|---|
| Public | `0.0.0.0/0` | Internet Gateway |
| Private | `0.0.0.0/0` | NAT Gateway |

### NACLs — Pública (Inbound)

| Regra | Protocolo | Porta(s) | Ação |
|---|---|---|---|
| 100 | TCP | 80 | Allow |
| 110 | TCP | 443 | Allow |
| 120 | TCP | 22 | Allow |
| 130 | TCP | 1024–65535 | Allow (ephemeral) |

### NACLs — Privada (Inbound)

| Regra | Protocolo | Porta(s) | Origem | Ação |
|---|---|---|---|---|
| 100 | TCP | 0–65535 | VPC CIDR | Allow |
| 110 | TCP | 1024–65535 | 0.0.0.0/0 | Allow (ephemeral via NAT) |

---

## Status

> 🚧 Portfolio em andamento
