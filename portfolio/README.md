# CloudLab — Case Study

> Plataforma de infraestrutura cloud production-grade na AWS, construída do zero com Terraform, Kubernetes (EKS), Helm e GitHub Actions. Demonstra práticas de DevOps e Platform Engineering ponta a ponta: provisionamento, deploy, observabilidade e segurança.

---

## O problema

Subir uma aplicação web em produção na AWS de forma **segura, observável e reproduzível** envolve dezenas de serviços que precisam conversar entre si: rede, compute, banco, cache, DNS, certificados, criptografia, CI/CD e monitoramento. Fazer isso "na mão" no console gera ambientes frágeis, sem versionamento e difíceis de auditar.

## A solução

O CloudLab entrega todo esse ambiente como código, com uma única fonte de verdade versionada em Git:

- **Infraestrutura como código** — 17 módulos Terraform compõem a stack inteira (VPC, EKS, ECS, RDS, ElastiCache, S3, ECR, KMS, Secrets Manager, IAM, ACM, Route53, ALB, EFS, CloudWatch, WAF, Security Groups).
- **Aplicações containerizadas** — backend (Node/Express) e frontend (React/nginx) empacotados em Helm charts, com HPA, PodDisruptionBudget e distribuição em 3 AZs.
- **CI/CD sem chaves estáticas** — GitHub Actions com autenticação OIDC; deploy Helm atômico com rollback automático; Terraform com aprovação manual em produção.
- **Observabilidade** — kube-prometheus-stack (Prometheus, Grafana, Alertmanager) com dashboard e alertas customizados.
- **Segurança em camadas** — WAF, KMS com rotação, Secrets Manager, IRSA, NetworkPolicies default-deny, Pod Security Standards e RBAC.

---

## Arquitetura em uma frase

Tráfego entra por **WAF → ALB (TLS 1.3)**, é roteado para **frontend e backend no EKS**, e o backend consome **RDS MySQL, ElastiCache Redis, S3 e Secrets Manager** — tudo em subnets privadas, criptografado por KMS.

Diagramas completos em [../diagrams/](../diagrams/).

---

## Destaques técnicos

| Área | O que foi demonstrado |
|---|---|
| Terraform | Padrão live + modules, encadeamento de outputs, tags padronizadas |
| Kubernetes | EKS 1.33, IRSA, add-ons (ALB Controller, EBS/EFS CSI, Cluster Autoscaler, Metrics Server) |
| Helm | Charts parametrizados, HPA, PDB, topologySpread em 3 AZs |
| CI/CD | OIDC (zero secrets estáticos), build/push ECR por SHA, deploy atômico, plan comentado no PR |
| Observabilidade | Métricas RED (Rate, Errors, Duration), alertas de erro/latência/crashloop |
| Segurança | Defesa em profundidade da borda ao pod; zero credenciais em código |

---

## Stack

`AWS` · `Terraform` · `Amazon EKS` · `ECS Fargate` · `Helm` · `GitHub Actions (OIDC)` · `Prometheus` · `Grafana` · `RDS MySQL` · `ElastiCache Redis` · `WAF` · `KMS` · `Secrets Manager` · `Node.js` · `React`

---

## Métricas do projeto

| Indicador | Valor |
|---|---|
| Módulos Terraform | 17 |
| Serviços AWS integrados | 17+ |
| Zonas de disponibilidade | 3 |
| Workflows CI/CD | 3 |
| Add-ons de cluster | 5 |
| Credenciais estáticas | 0 (OIDC + IRSA + Secrets Manager) |

---

## Competências evidenciadas

- **Cloud / AWS**: desenho de VPC multi-AZ, EKS, dados gerenciados, borda segura.
- **IaC**: modularização, composição e reprodutibilidade com Terraform.
- **Platform Engineering**: golden paths e GitOps (ver [../platform/](../platform/)).
- **DevOps / SRE**: pipelines, observabilidade, runbooks e resposta a incidentes.
- **Segurança**: least privilege, criptografia, políticas de rede e de pod.

---

## Como explorar

| Quero ver... | Onde |
|---|---|
| Visão geral e índice | [../docs/README.md](../docs/README.md) |
| Arquitetura detalhada | [../docs/architecture.md](../docs/architecture.md) |
| Infraestrutura Terraform | [../docs/infrastructure.md](../docs/infrastructure.md) |
| Deploy e CI/CD | [../docs/deployment.md](../docs/deployment.md) |
| Operações (monitoring/segurança) | [../docs/operations.md](../docs/operations.md) |
| Aplicações de exemplo | [../docs/applications.md](../docs/applications.md) |
| Diagramas | [../diagrams/](../diagrams/) |

---

## Sobre

Projeto de portfólio por **Wellington**, focado em demonstrar infraestrutura cloud e Platform Engineering de nível de produção.
