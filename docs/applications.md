# Aplicações

O CloudLab traz duas aplicações de exemplo em `applications/`, já alinhadas com os contratos impostos pela infraestrutura (Helm charts, ALB, monitoring). O CI faz build de cada uma a partir do seu diretório e envia a imagem ao ECR.

## Backend (`applications/backend`)

Node.js 20 + Express.

### Estrutura

```
applications/backend/
├── Dockerfile          # multi-stage, roda como usuário não-root
├── .dockerignore
├── package.json
├── README.md
└── src/
    ├── server.js       # app Express: /health, /metrics, /api/*
    ├── config.js       # leitura de env (DB, Redis, porta)
    ├── db.js           # pool MySQL + cliente Redis + checkHealth()
    └── metrics.js      # prom-client (http_requests_total, latência)
```

### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| GET | `/health` | Liveness/readiness. Sempre `200`; corpo reporta `database`/`cache` |
| GET | `/metrics` | Métricas Prometheus (scrape do ServiceMonitor) |
| GET | `/api` | Identificação do serviço |
| GET | `/api/items` | Exemplo que usa cache Redis (fallback para origem) |

### Contratos atendidos

- Porta `8080` (= `helm-charts/backend/values.yaml → service.port`).
- Probes em `GET /health`.
- Rotas de negócio sob `/api/*` (o ALB roteia `/api/*` para o backend).
- Env `DB_HOST`/`DB_PORT`/`DB_NAME`/`REDIS_HOST`/`REDIS_PORT` e secret `cloudlab-rds` (`USERNAME`/`PASSWORD`).
- Métricas com label `app="backend"`, nomes `http_requests_total` e `http_request_duration_seconds_bucket`, exatamente como consultados por `monitoring/prometheus/alerts.yaml` e pelo dashboard do Grafana.

### Rodar local

```bash
cd applications/backend
npm install
npm start
curl localhost:8080/health
curl localhost:8080/api/items
curl localhost:8080/metrics
```

Sem MySQL/Redis locais, `/health` retorna `200` com as dependências como `down`.

## Frontend (`applications/frontend`)

React 18 + Vite, servido por nginx em produção.

### Estrutura

```
applications/frontend/
├── Dockerfile             # build Vite -> nginx:alpine (não-root)
├── .dockerignore
├── nginx.conf             # SPA fallback, /metrics, /healthz
├── docker-entrypoint.sh   # injeta API_URL em runtime (window.__API_URL__)
├── index.html
├── vite.config.js         # proxy /api -> localhost:8080 em dev
├── package.json
├── README.md
└── src/
    ├── main.jsx
    ├── App.jsx            # consome ${API_URL}/items
    └── styles.css
```

### Injeção da API_URL em runtime

A mesma imagem serve qualquer ambiente. No start do container, `docker-entrypoint.sh`
lê a env `API_URL` e gera `/config.js` (`window.__API_URL__`), carregado pelo
`index.html` antes do bundle. No CD, o valor é `https://cloudlab.example.com/api`.
`App.jsx` cai em `/api` (relativo) caso a env não esteja definida.

### Contratos atendidos

- Porta `80` (= `helm-charts/frontend/values.yaml → service.port`).
- `GET /` serve a SPA (usado pelos probes); `GET /healthz` extra.
- `GET /metrics` retorna um stub para o scrape do ServiceMonitor não falhar.
- Roda como usuário não-root, compatível com o Pod Security Standard `restricted`.

> O nginx não expõe métricas Prometheus nativas. Para métricas ricas de HTTP no
> frontend, adicionar um sidecar `nginx-prometheus-exporter`.

### Rodar local

```bash
cd applications/frontend
npm install
npm run dev        # http://localhost:5173 (proxy /api -> localhost:8080)
npm run build      # gera dist/
```

## Pipeline

`ci.yaml` faz build/push das duas imagens no ECR (tags `<sha8>` e `latest`), e
`cd.yaml` implanta via Helm no EKS. Detalhes em [deployment.md](./deployment.md).

## Observações e próximos passos

- As aplicações são exemplos funcionais para validar a plataforma ponta a ponta (build, deploy, health, métricas, cache). Substitua a lógica de negócio conforme a necessidade real.
- O backend expõe métricas ricas; o frontend expõe apenas um stub de `/metrics`.
- Nenhum lockfile foi versionado inicialmente; o `npm install` gera `package-lock.json` — mantê-lo versionado é recomendado para builds reprodutíveis.
