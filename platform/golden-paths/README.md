# Golden Paths

Caminhos pavimentados para criar novos componentes já alinhados com a plataforma CloudLab. A ideia é que um time comece de um template pronto em vez de recriar Dockerfile, Helm chart e pipeline do zero.

## Contratos da plataforma (o que todo serviço deve cumprir)

Derivados dos Helm charts e do monitoring existentes:

| Contrato | Requisito |
|---|---|
| Porta | Definida em `service.port` do chart (backend 8080, frontend 80) |
| Health | `GET /health` retornando 200 (usado por liveness/readiness) |
| Métricas | `GET /metrics` no formato Prometheus, scrapeado pelo ServiceMonitor |
| Labels de métrica | `http_requests_total{app,status}` e `http_request_duration_seconds_bucket` |
| Namespace | `app` |
| Imagem | Publicada no ECR, tag = SHA curto do commit |
| Segurança | Container não-root (Pod Security Standard `restricted`) |

## Templates disponíveis

| Template | Base de referência |
|---|---|
| [service-node/](./service-node/) | Microserviço HTTP em Node/Express (espelha `applications/backend`) |

## Como usar um golden path

1. Copie a pasta do template para `applications/<seu-serviço>`.
2. Substitua os placeholders (`__SERVICE_NAME__`, `__PORT__`).
3. Crie um Helm chart a partir de `helm-charts/backend` como referência.
4. Adicione o serviço ao pipeline (`applications/**` já dispara o CI).
5. Registre o serviço no [catálogo](../catalog/).

## Próximos passos

- Adicionar templates para outras stacks (Python/FastAPI, Go).
- Automatizar o scaffolding (ex: `cookiecutter`, gerador do Backstage, ou script em `tools/`).
