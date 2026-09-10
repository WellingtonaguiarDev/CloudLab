# Security Checklist — CloudLab

## Infraestrutura (Terraform)

- [x] VPC com subnets públicas e privadas separadas
- [x] NAT Gateway para egress das subnets privadas
- [x] NACLs restritivas em subnets públicas e privadas
- [x] RDS em subnet privada, sem acesso público
- [x] RDS com storage encryption habilitado
- [x] ElastiCache com at-rest e in-transit encryption
- [x] EFS com encryption habilitado via KMS
- [x] S3 com Block Public Access completo
- [x] S3 com SSE-S3 encryption
- [x] KMS com key rotation automática habilitada
- [x] Secrets Manager com KMS encryption
- [x] Security Groups com princípio do menor privilégio
- [x] IAM roles com políticas mínimas necessárias
- [x] IRSA para todos os workloads (zero credenciais em pods)
- [x] WAF com managed rules (CommonRuleSet, SQLi, KnownBadInputs)
- [x] WAF com rate limiting por IP
- [x] ACM com validação DNS automática
- [x] ALB com redirect HTTP → HTTPS
- [x] ALB com TLS policy moderna (TLS 1.3)

## Kubernetes

- [x] Pod Security Standards: `restricted` no namespace app
- [x] Pod Security Standards: `baseline` no namespace monitoring
- [x] NetworkPolicy default-deny-all em todos os namespaces
- [x] NetworkPolicy com allow seletivo por porta e seletor
- [x] RBAC com roles mínimas (developer, readonly)
- [x] ServiceAccounts dedicados por workload
- [x] IRSA annotations nos ServiceAccounts dos controllers
- [x] PodDisruptionBudget em todos os deployments

## CI/CD

- [x] Autenticação AWS via OIDC (sem access keys)
- [x] Terraform apply com aprovação manual (environment: production)
- [x] Imagens com tags imutáveis (SHA do commit)
- [x] ECR com image scanning on push
- [x] ECR com tag immutability

## Pendências recomendadas para produção real

- [ ] Habilitar AWS GuardDuty
- [ ] Habilitar AWS Security Hub
- [ ] Habilitar AWS Config Rules
- [ ] Habilitar CloudTrail em todas as regiões
- [ ] Configurar Alertmanager com SNS/PagerDuty
- [ ] Rotação automática de secrets no Secrets Manager
- [ ] Multi-AZ no RDS
- [ ] Backup cross-region no S3
- [ ] VPC Flow Logs habilitados
