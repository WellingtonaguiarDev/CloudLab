# CloudLab Backend

API do CloudLab em Node.js + Express.

## Contratos com a infraestrutura

| Item | Valor | Origem |
|---|---|---|
| Porta | `8080` | `helm-charts/backend/values.yaml` (`service.port`) |
| Health check | `GET /health` | probes de liveness/readiness do chart |
| Métricas | `GET /metrics` (Prometheus) | `monitoring/prometheus/servicemonitor.yaml` |
| Rotas de negócio | `GET /api/*` | roteamento `/api/*` no ALB |

## Variáveis de ambiente

| Variável | Default | Fonte no deploy |
|---|---|---|
| `PORT` | `8080` | — |
| `DB_HOST` / `DB_PORT` / `DB_NAME` | `localhost` / `3306` / `cloudlab` | `env` do chart |
| `USERNAME` / `PASSWORD` | — | secret `cloudlab-rds` (`envFromSecrets`) |
| `REDIS_HOST` / `REDIS_PORT` | `localhost` / `6379` | `env` do chart |

## Métricas expostas

- `http_requests_total{app="backend", method, route, status}`
- `http_request_duration_seconds_bucket{app="backend", ...}` (para p99)
- métricas padrão de processo Node

Esses nomes/labels são consumidos por `monitoring/prometheus/alerts.yaml` e pelo dashboard `monitoring/grafana/dashboards/cloudlab.yaml`.

## Rodar local

```bash
npm install
npm start
# http://localhost:8080/health
# http://localhost:8080/metrics
# http://localhost:8080/api/items
```

Sem MySQL/Redis locais o `/health` responde `200` com `database`/`cache` marcados como `down`.

## Build da imagem

```bash
docker build -t cloudlab-backend .
docker run -p 8080:8080 cloudlab-backend
```
