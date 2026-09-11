# Arquitetura

O CloudLab é um ambiente de produção AWS single-region (`us-east-1`) que hospeda uma aplicação web (backend + frontend) sobre Amazon EKS, com ECS Fargate para workloads alternativos. Toda a infraestrutura é declarada em Terraform e as aplicações são implantadas via Helm.

## Fluxo de tráfego

```
Internet
    │
    ▼
 [WAF v2]                    CommonRuleSet, SQLi, KnownBadInputs, rate limit 2000/5min
    │
    ▼
 [ALB]  ── HTTPS (ACM/TLS 1.3) ── Route53 (ALIAS)
    │        redirect HTTP → HTTPS
    │
    ├── /api/*  ──► [EKS] backend  ──► [RDS MySQL 8.4]
    │                               ──► [ElastiCache Redis 7.1]
    │                               ──► [S3]
    │                               ──► [Secrets Manager]
    │
    └── /*      ──► [EKS] frontend

 [ECS Fargate]  ── workloads alternativos (nginx)
 [EFS]          ── storage compartilhado montado no EKS
 [ECR]          ── registry de imagens (backend/frontend)
 [CloudWatch]   ── logs, alarmes e dashboard
 [KMS]          ── criptografia centralizada (RDS / S3 / Secrets)
```

## Componentes principais

| Camada | Serviço AWS | Papel na arquitetura |
|---|---|---|
| Borda / segurança | WAF v2 | Filtra requisições maliciosas antes do ALB |
| Entrada | ALB | Termina TLS, roteia `/api/*` e `/*`, redirect HTTP→HTTPS |
| DNS | Route53 | Zona hospedada + registros ALIAS apontando ao ALB |
| Certificados | ACM | Certificado TLS validado por DNS |
| Compute (principal) | EKS 1.33 | Executa backend e frontend em nós `t3.medium` |
| Compute (alternativo) | ECS Fargate | Executa serviço `nginx` serverless |
| Banco de dados | RDS MySQL 8.4 | Persistência relacional em subnet privada |
| Cache | ElastiCache Redis 7.1 | Cache em memória com criptografia at-rest/in-transit |
| Object storage | S3 | Armazenamento de objetos (SSE-S3, Block Public Access) |
| Storage compartilhado | EFS | Sistema de arquivos montado nos pods via CSI |
| Registry | ECR | Imagens de container com tags imutáveis e scan on push |
| Segredos | Secrets Manager | Credenciais do RDS, criptografadas por KMS |
| Criptografia | KMS | 3 chaves dedicadas (rds, s3, secrets) com rotação |
| Observabilidade | CloudWatch | Log groups, alarmes e dashboard |

## Rede

A VPC `PROD-cloudlab-VPC` (`172.22.0.0/16`) usa 3 zonas de disponibilidade, com subnets públicas e privadas em cada AZ.

| Camada | Subnets | Uso |
|---|---|---|
| Pública | `172.22.0.0/20`, `172.22.16.0/20`, `172.22.32.0/20` | ALB, NAT Gateway, Internet Gateway |
| Privada | `172.22.64.0/19`, `172.22.96.0/19`, `172.22.128.0/19` | Nós EKS, ECS, RDS, ElastiCache, EFS |

- Um único **NAT Gateway** (com EIP dedicado na subnet pública A) provê saída para a internet a partir das subnets privadas.
- **NACLs** separadas para camadas pública e privada.
- Recursos sensíveis (RDS, Redis, EFS) ficam exclusivamente em subnets privadas, sem acesso público.

## Decisões de design

- **EKS como plataforma principal**: backend e frontend rodam no cluster Kubernetes, com autoscaling por HPA e distribuição em 3 AZs via `topologySpreadConstraints`.
- **IRSA em todos os workloads**: cada ServiceAccount recebe uma role IAM via OIDC, eliminando credenciais estáticas dentro dos pods.
- **Zero credenciais em código**: senhas e credenciais do banco vivem no Secrets Manager, injetadas nos pods em tempo de deploy.
- **Criptografia em repouso por toda parte**: RDS, S3, EFS, ElastiCache e Secrets Manager usam chaves KMS com rotação automática.
- **Defesa em profundidade**: WAF na borda, Security Groups por serviço, NetworkPolicies default-deny no cluster e Pod Security Standards `restricted`.
- **Alta disponibilidade**: 3 AZs, PodDisruptionBudget, e node group com min 2 / max 4.

## Estados atuais e observações

- O **backend de state S3** está comentado em `backend.tf`; o Terraform usa state local por enquanto.
- Domínio de exemplo `cloudlab.example.com` configurado em ACM e Route53 — deve ser substituído por um domínio real.
- As **aplicações** (`applications/backend`, `applications/frontend`) são placeholders; as imagens são construídas a partir desses diretórios no pipeline de CI.

Consulte [infrastructure.md](./infrastructure.md) para o detalhe de cada módulo Terraform e [deployment.md](./deployment.md) para o fluxo de deploy.
