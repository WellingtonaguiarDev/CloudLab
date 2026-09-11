# Infraestrutura (Terraform)

Toda a infraestrutura AWS do CloudLab é declarada em Terraform, seguindo o padrão **live + modules**: os módulos reutilizáveis ficam em `infrastructure/terraform/modules/`, e a composição do ambiente real (`cloudlab`) fica em `infrastructure/terraform/live/cloudlab/`.

## Layout

```
infrastructure/
├── bootstrap/                 # Reservado (bootstrap de state/backend)
└── terraform/
    ├── live/
    │   └── cloudlab/          # Raiz do ambiente de produção
    │       ├── backend.tf     # Backend S3 (comentado / desabilitado)
    │       ├── locals.tf      # Tags comuns (Environment, Project, Owner)
    │       ├── modules.tf     # Orquestração de todos os módulos
    │       ├── outputs.tf     # (vazio no momento)
    │       ├── providers.tf   # provider aws { region }
    │       ├── terraform.tfvars
    │       ├── variables.tf   # region, environment
    │       └── versions.tf    # required_providers
    └── modules/               # 17 módulos reutilizáveis
```

## Providers e versões

Definidos em `live/cloudlab/versions.tf`:

| Provider | Versão | Uso |
|---|---|---|
| `hashicorp/aws` | `~> 6.0` | Todos os recursos AWS |
| `hashicorp/tls` | `~> 4.0` | Geração de material TLS |

O provider AWS é configurado com a região vinda da variável `region` (`providers.tf`). O Terraform CLI usado no pipeline é `~1.9` (ver [deployment.md](./deployment.md)).

## Variáveis e tags

`variables.tf` define apenas duas entradas de ambiente:

```hcl
variable "region" {}
variable "environment" {}
```

Valores em `terraform.tfvars`:

```hcl
region      = "us-east-1"
environment = "production"
```

Tags comuns aplicadas via `local.tags` (`locals.tf`):

```hcl
locals {
  tags = {
    Environment = var.environment
    Project     = "CloudLab"
    Owner       = "Wellington"
  }
}
```

## Backend de state

O backend remoto S3 está **comentado** em `backend.tf`:

```hcl
#terraform {
#  backend "s3" {}
#}
```

Enquanto comentado, o Terraform usa **state local**. Para uso em equipe/produção, habilite o backend S3 (idealmente com uma tabela DynamoDB para lock) — a pasta `infrastructure/bootstrap/` está reservada para provisionar esses recursos de state.

## Módulos e orquestração

Os módulos são compostos em `modules.tf`, encadeando outputs de uns como inputs de outros (por exemplo, `module.vpc.network` alimenta EKS, ECS, RDS, EFS e ElastiCache; `module.kms.key_arns` alimenta os módulos que precisam de criptografia).

| Módulo | Serviço AWS | Detalhes de configuração |
|---|---|---|
| `vpc` | Virtual Private Cloud | 3 AZs, subnets públicas/privadas, NAT Gateway, NACLs. CIDR `172.22.0.0/16` |
| `eks` | Elastic Kubernetes Service | v1.33, node group `t3.medium`, desired 2 / min 2 / max 4, OIDC/IRSA |
| `ecs` | Elastic Container Service | Fargate, serviço `nginx` (`nginx:latest`), rede `awsvpc` |
| `rds` | Relational Database Service | MySQL 8.4, subnet privada da VPC |
| `s3` | Simple Storage Service | Bucket `cloudlab-storage`, SSE-S3, Block Public Access |
| `ecr` | Elastic Container Registry | Repositórios `backend` e `frontend`, tags imutáveis, scan on push |
| `kms` | Key Management Service | 3 chaves (`rds`, `s3`, `secrets`) com rotação automática |
| `secrets-manager` | Secrets Manager | Segredo `cloudlab/rds` (engine/host/port/dbname/username), criptografado por KMS |
| `iam` | Identity and Access Management | Roles IRSA para backend e controllers do cluster |
| `security-groups` | Security Groups | SGs para ALB, ElastiCache e EFS |
| `acm` | Certificate Manager | Certificado `cloudlab.example.com` + SAN `*.cloudlab.example.com`, validação DNS |
| `route53` | Route 53 | Zona hospedada e registros ALIAS para o ALB |
| `alb` | Application Load Balancer | Subnets públicas, HTTP→HTTPS, TLS via ACM |
| `efs` | Elastic File System | Subnets privadas, criptografia KMS |
| `elasticache` | ElastiCache | Redis 7.1, criptografia at-rest + in-transit |
| `cloudwatch` | CloudWatch | Log groups, alarmes (RDS/ECS/ALB) e dashboard |
| `waf` | Web Application Firewall | Associado ao ALB, `rate_limit = 2000` |

### Dependências entre módulos (resumo)

```
vpc ──► eks ──► iam (via oidc_provider_arn/url)
vpc ──► ecs, rds, efs, elasticache, security-groups, alb
kms ──► secrets-manager, cloudwatch, efs, elasticache
alb ──► waf, cloudwatch, route53, acm
route53 ──► acm (validação DNS)
rds ──► secrets-manager (host/port/dbname/username)
```

### IRSA (IAM Roles for Service Accounts)

O módulo `iam` recebe o OIDC provider do EKS e cria roles para os service accounts abaixo:

| ServiceAccount | Namespace | Políticas |
|---|---|---|
| `backend` | `app` | S3 read/write + Secrets Manager read-only (policies do próprio módulo) |
| `aws-load-balancer-controller` | `kube-system` | `ElasticLoadBalancingFullAccess` |
| `ebs-csi-controller-sa` | `kube-system` | `AmazonEBSCSIDriverPolicy` |
| `efs-csi-controller-sa` | `kube-system` | `AmazonEFSCSIDriverPolicy` |
| `cluster-autoscaler` | `kube-system` | `AutoScalingFullAccess` |

## Detalhes por serviço

### VPC
- Nome `PROD-cloudlab-VPC`, CIDR `172.22.0.0/16`, DNS support + hostnames habilitados.
- Internet Gateway + 1 NAT Gateway (EIP dedicado na subnet pública A).
- 3 subnets públicas (`/20`) e 3 privadas (`/19`), uma por AZ.

### EKS
- Cluster `cloudlab-eks`, versão `1.33`, nós em subnets privadas.
- Node group `cloudlab-eks-default`, `t3.medium`, desired 2 / min 2 / max 4.
- OIDC provider habilitado para IRSA.

### ECS
- Cluster `cloudlab-ecs`, launch type Fargate, serviço `nginx` na porta 80, CPU 256 / memória 512, rede `awsvpc` em subnets privadas.

### RDS
- Identifier `cloudlab-mysql`, MySQL 8.4, `db.t3.micro`, 20 GB (autoscaling até 100 GB).
- Criptografado, sem acesso público, backup 7 dias, credenciais no Secrets Manager (`cloudlab/rds`).

### KMS
| Chave | Alias | Uso |
|---|---|---|
| cloudlab-kms-rds | `alias/cloudlab-rds` | Criptografia do RDS |
| cloudlab-kms-s3 | `alias/cloudlab-s3` | Criptografia de S3 / EFS / ElastiCache |
| cloudlab-kms-secrets | `alias/cloudlab-secrets` | Criptografia do Secrets Manager |

## Comandos

```bash
cd infrastructure/terraform/live/cloudlab

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> No pipeline, o `apply` roda com `-auto-approve` apenas após aprovação manual do environment `production`. Consulte [deployment.md](./deployment.md).
