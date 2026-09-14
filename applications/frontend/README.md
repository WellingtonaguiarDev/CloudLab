# CloudLab Frontend

SPA em React (Vite), servida por nginx em produção.

## Contratos com a infraestrutura

| Item | Valor | Origem |
|---|---|---|
| Porta | `80` | `helm-charts/frontend/values.yaml` (`service.port`) |
| Health check | `GET /` (probes) / `GET /healthz` (extra) | chart |
| Métricas | `GET /metrics` (stub) | `monitoring/prometheus/servicemonitor.yaml` |
| API | `API_URL` injetada em runtime | `env.API_URL` do chart / CD |

## Como a API_URL é injetada

A mesma imagem serve qualquer ambiente. No start do container, `docker-entrypoint.sh`
lê a env `API_URL` e gera `/config.js` com `window.__API_URL__`, carregado pelo
`index.html` antes do bundle. No pipeline de CD, o valor é
`https://cloudlab.example.com/api`.

## Rodar local

```bash
npm install
npm run dev      # http://localhost:5173 (proxy /api -> localhost:8080)
```

## Build e imagem

```bash
npm run build    # gera dist/
docker build -t cloudlab-frontend .
docker run -p 8080:80 -e API_URL=/api cloudlab-frontend
```

> Observação: o nginx não expõe métricas Prometheus nativas. O `/metrics` atual
> é um stub para o scrape do ServiceMonitor não falhar. Para métricas reais,
> adicionar um sidecar `nginx-prometheus-exporter`.
