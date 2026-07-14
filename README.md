# CloudLab

Portfolio de infraestrutura cloud em andamento, com foco em AWS usando Terraform, Kubernetes, Helm e práticas modernas de DevOps/Platform Engineering.

---

## Visão Geral

| Item | Detalhe |
|---|---|
| Owner | Wellington |
| Ambiente | production |
| Região AWS | us-east-1 (Norte da Virgínia) |
| Terraform AWS Provider | ~> 6.0 |
| State Backend | S3 (desabilitado) |

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
│       │       ├── backend.tf        # Remote state S3 (comentado)
│       │       ├── locals.tf         # Tags padrão (Environment, Project, Owner)
│       │       ├── modules.tf        # Orquestração de todos os módulos
│       │       ├── outputs.tf
│       │       ├── providers.tf      # Provider AWS (região via variável)
│       │       ├── terraform.tfvars  # us-east-1 / production
│       │       ├── variables.tf      # region, environment
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
│           │   ├── main.tf
│           │   ├── outputs.tf
│           │   ├── parameter_group.tf
│           │   ├── random_password.tf
│           │   ├── security_group.tf
│           │   ├── subnet_group.tf
│           │   └── variables.tf
│           ├── route53/
│           ├── s3/
│           │   ├── main.tf
│           │   ├── outputs.tf
│           │   └── variables.tf
│           ├── security-groups/
│           ├── secrets-manager/
│           ├── vpc/
│           │   ├── acls.tf
│           │   ├── eip_natgateway.tf
│           │   ├── internet_gateway.tf
│           │   ├── locals.tf
│           │   ├── outputs.tf
│           │   ├── route_tables.tf
│           │   ├── subnets.tf
│           │   ├── variables.tf
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

### NACLs — Pública (Outbound)

| Regra | Protocolo | Porta(s) | Destino | Ação |
|---|---|---|---|---|
| 100 | TCP | 80 | 0.0.0.0/0 | Allow |
| 110 | TCP | 443 | 0.0.0.0/0 | Allow |
| 120 | TCP | 0–65535 | VPC CIDR | Allow |
| 130 | TCP | 1024–65535 | 0.0.0.0/0 | Allow (ephemeral) |

### NACLs — Privada (Inbound)

| Regra | Protocolo | Porta(s) | Origem | Ação |
|---|---|---|---|---|
| 100 | TCP | 0–65535 | VPC CIDR | Allow |
| 110 | TCP | 1024–65535 | 0.0.0.0/0 | Allow (ephemeral via NAT) |

### NACLs — Privada (Outbound)

| Regra | Protocolo | Porta(s) | Destino | Ação |
|---|---|---|---|---|
| 100 | TCP | 80 | 0.0.0.0/0 | Allow |
| 110 | TCP | 443 | 0.0.0.0/0 | Allow |
| 120 | TCP | 0–65535 | VPC CIDR | Allow |

### Outputs do Módulo VPC

| Output | Descrição |
|---|---|
| `id` | VPC ID |
| `arn` | VPC ARN |
| `cidr_block` | VPC CIDR Block |
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_id` | NAT Gateway ID |
| `nat_gateway_public_ip` | IP público do NAT Gateway |
| `nat_gateway_allocation_id` | EIP Allocation ID |
| `public_route_table_id` | Route Table pública ID |
| `private_route_table_id` | Route Table privada ID |
| `public_network_acl_id` | NACL pública ID |
| `private_network_acl_id` | NACL privada ID |
| `public_subnet_ids` | Lista de IDs das subnets públicas |
| `private_subnet_ids` | Lista de IDs das subnets privadas |
| `network` | Objeto completo com toda a informação de rede |

---

## Módulo RDS

| Atributo | Valor |
|---|---|
| Identifier | `cloudlab-mysql` |
| Engine | MySQL 8.4 |
| Instance Class | `db.t3.micro` |
| Storage | 20 GB (autoscaling até 100 GB) |
| Database Name | `cloudlab` |
| Master User | `admin` |
| Password | Gerada via `random_password` (32 chars) |
| Multi-AZ | ❌ |
| Backup Retention | 7 dias |
| Storage Encrypted | ✅ |
| Publicly Accessible | ❌ |
| Deletion Protection | ❌ |
| Parameter Group | `mysql8.4` (utf8mb4) |
| Subnet Group | Subnets privadas da VPC |
| Security Group | Ingress MySQL 3306 restrito ao VPC CIDR |
| Dependência | `module.vpc.network` |

### Outputs do Módulo RDS

| Output | Descrição |
|---|---|
| `id` | RDS Instance ID |
| `arn` | RDS Instance ARN |
| `endpoint` | Connection endpoint |
| `address` | Hostname |
| `port` | Porta |
| `database_name` | Nome do banco |
| `username` | Master username |
| `security_group_id` | Security Group ID |
| `subnet_group_name` | Subnet Group name |
| `parameter_group_name` | Parameter Group name |
| `instance_class` | Classe da instância |

---

## Módulo S3

| Atributo | Valor |
|---|---|
| Bucket Name | `cloudlab-storage` |
| Encryption | AES256 (SSE-S3) |
| Block Public ACLs | ✅ |
| Block Public Policy | ✅ |
| Ignore Public ACLs | ✅ |
| Restrict Public Buckets | ✅ |

### Outputs do Módulo S3

| Output | Descrição |
|---|---|
| `id` | Bucket ID |
| `arn` | Bucket ARN |
| `bucket_name` | Nome do bucket |
| `domain_name` | Bucket domain name |

---

## Status

> 🚧 Portfolio em andamento
