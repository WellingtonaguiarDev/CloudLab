# Golden Path — Serviço Node/Express

Template mínimo de microserviço HTTP alinhado com os contratos da plataforma CloudLab. Espelha `applications/backend`, mas enxuto para servir de ponto de partida.

## Placeholders

| Placeholder | Descrição | Exemplo |
|---|---|---|
| `__SERVICE_NAME__` | Nome do serviço | `orders` |
| `__PORT__` | Porta HTTP | `8080` |

## O que já vem pronto

- `GET /health` — para os probes do Kubernetes.
- `GET /metrics` — Prometheus, com label `app=__SERVICE_NAME__` e as métricas `http_requests_total` / `http_request_duration_seconds` que o dashboard e os alertas consomem.
- `GET /api` — ponto de partida para as rotas de negócio.
- Encerramento gracioso (SIGTERM) para rollout limpo.

## Passos

1. Copie esta pasta para `applications/__SERVICE_NAME__`.
2. Faça find/replace de `__SERVICE_NAME__` e `__PORT__`.
3. Adicione um `Dockerfile` (use `applications/backend/Dockerfile` como base).
4. Crie o Helm chart a partir de `helm-charts/backend`.
5. Registre no catálogo em `platform/catalog/`.

## Rodar local

```bash
npm install
PORT=__PORT__ npm start
```
