# Documentação CloudLab

Documentação técnica do **CloudLab**, um portfólio de infraestrutura cloud na AWS construído com Terraform, Kubernetes (EKS), Helm e práticas modernas de DevOps / Platform Engineering.

## Índice

| Documento | Conteúdo |
|---|---|
| [getting-started.md](./getting-started.md) | Pré-requisitos, ferramentas e passo a passo para provisionar e implantar o ambiente do zero |
| [architecture.md](./architecture.md) | Visão de arquitetura, fluxo de tráfego, componentes AWS e decisões de design |
| [infrastructure.md](./infrastructure.md) | Terraform: layout `live`/`modules`, providers, e detalhe de cada módulo |
| [deployment.md](./deployment.md) | Helm charts (backend/frontend) e pipelines de CI/CD com GitHub Actions |
| [operations.md](./operations.md) | Monitoring, segurança, add-ons do cluster e runbooks operacionais |

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
├── tests/ · tools/ · plataform/ · portfolio/   # Reservados
└── README.md
```

> As pastas `applications/`, `diagrams/`, `tests/`, `tools/`, `plataform/` e `portfolio/` atualmente contêm apenas placeholders (`.gitkeep`) e estão reservadas para evolução do projeto.

## Estado das áreas

| Área | Situação |
|---|---|
| Infraestrutura Terraform | Implementada (17 módulos) |
| Helm charts | Implementados (backend + frontend) |
| CI/CD | Implementado (3 workflows) |
| Monitoring | Implementado (Prometheus + Grafana) |
| Security | Implementado (NetworkPolicy, PSS, RBAC) |
| Runbooks | Implementados (4 documentos) |
| Código das aplicações | Placeholder (a ser adicionado) |
