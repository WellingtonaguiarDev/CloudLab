# Documentação CloudLab

Documentação técnica do **CloudLab**, um portfólio de infraestrutura cloud na AWS construído com Terraform, Kubernetes (EKS), Helm e práticas modernas de DevOps / Platform Engineering.

## Índice

| Documento | Conteúdo |
|---|---|
| [../RUNBOOK.md](../RUNBOOK.md) | **Passo a passo completo** do clone ao ambiente no ar (walkthrough sequencial) |
| [getting-started.md](./getting-started.md) | Pré-requisitos, ferramentas e referência das etapas de provisionamento/deploy |
| [architecture.md](./architecture.md) | Visão de arquitetura, fluxo de tráfego, componentes AWS e decisões de design |
| [infrastructure.md](./infrastructure.md) | Terraform: layout `live`/`modules`, providers, e detalhe de cada módulo |
| [deployment.md](./deployment.md) | Helm charts (backend/frontend) e pipelines de CI/CD com GitHub Actions |
| [operations.md](./operations.md) | Monitoring, segurança, add-ons do cluster e runbooks operacionais |
| [applications.md](./applications.md) | Aplicações backend (Node/Express) e frontend (React + nginx) |

## Resumo do projeto

| Item | Detalhe |
|---|---|
| Owner | Wellington |
| Ambiente | production |
| Região AWS | us-east-1 (Norte da Virgínia) |
| IaC | Terraform (AWS `~> 6.0`, TLS `~> 4.0`) |
| Orquestração | Amazon EKS 1.33 + ECS Fargate |
| Package manager | Helm |
| CI/CD | GitHub Actions com autenticação OIDC |
| Observabilidade | kube-prometheus-stack (Prometheus + Grafana + Alertmanager) |
| State backend | S3 (atualmente comentado / desabilitado) |

## Estrutura do repositório

```
CloudLab/
├── applications/        # Código das apps (backend/frontend) — placeholders
├── cicd/.github/        # Workflows GitHub Actions (ci, cd, terraform)
├── diagrams/            # Diagramas de arquitetura
├── docs/                # Esta documentação
├── helm-charts/         # Charts Helm de backend e frontend
├── infrastructure/      # Terraform (live + modules) e bootstrap
├── kubernetes/          # Manifests dos add-ons do kube-system
├── monitoring/          # Configuração de Prometheus e Grafana
├── runbooks/            # Procedimentos operacionais
├── security/            # NetworkPolicies, Pod Security, RBAC, checklist
├── platform/            # Platform Engineering: golden paths, GitOps, catálogo
├── portfolio/           # Case study de apresentação do projeto
├── tests/               # Testes de validação (Terraform, Helm, smoke do backend)
├── tools/               # Scripts utilitários (validate, deploy, kubeconfig, scaffolding)
└── README.md
```

> Todas as pastas do projeto já contêm conteúdo: `applications/` (apps de exemplo), `diagrams/` (diagramas Mermaid), `platform/` (Platform Engineering), `portfolio/` (case study), `tests/` (validação) e `tools/` (utilitários).

## Estado das áreas

| Área | Situação |
|---|---|
| Infraestrutura Terraform | Implementada (17 módulos) |
| Helm charts | Implementados (backend + frontend) |
| CI/CD | Implementado (3 workflows) |
| Monitoring | Implementado (Prometheus + Grafana) |
| Security | Implementado (NetworkPolicy, PSS, RBAC) |
| Runbooks | Implementados (4 documentos) |
| Código das aplicações | Implementado (backend Node/Express + frontend React/nginx) |
| Platform Engineering | Esqueleto (golden paths, GitOps/Argo CD, catálogo) |
| Portfolio | Case study de apresentação |
| Tests | Validação de Terraform, Helm e smoke do backend |
| Tools | Scripts de validação, deploy, kubeconfig e scaffolding |
