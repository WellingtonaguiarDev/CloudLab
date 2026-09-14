"use strict";

const express = require("express");

const config = require("./config");
const { metricsMiddleware, metricsHandler } = require("./metrics");
const { checkHealth } = require("./db");

const app = express();
app.disable("x-powered-by");
app.use(express.json());
app.use(metricsMiddleware);

// Exposição de métricas Prometheus. O ServiceMonitor faz scrape em /metrics.
app.get("/metrics", metricsHandler);

// Health check usado pelos probes de liveness/readiness (GET /health).
// Responde 200 mesmo com dependências fora, para não derrubar o pod por uma
// indisponibilidade transitória de RDS/Redis; o corpo reporta o detalhe.
app.get("/health", async (_req, res) => {
  const deps = await checkHealth();
  res.status(200).json({ status: "ok", ...deps });
});

// Rotas de negócio ficam sob /api/* (o ALB roteia /api/* para o backend).
const api = express.Router();

api.get("/", (_req, res) => {
  res.json({ service: "cloudlab-backend", version: "1.0.0" });
});

// Exemplo simples que exercita o cache Redis.
api.get("/items", async (_req, res) => {
  const { getRedis } = require("./db");
  try {
    const redis = getRedis();
    if (redis.status !== "ready") await redis.connect();
    const cached = await redis.get("items");
    if (cached) {
      return res.json({ source: "cache", items: JSON.parse(cached) });
    }
    const items = [
      { id: 1, name: "alpha" },
      { id: 2, name: "beta" },
    ];
    await redis.set("items", JSON.stringify(items), "EX", 30);
    return res.json({ source: "origin", items });
  } catch (err) {
    // Sem cache disponível, ainda retorna os dados de origem.
    return res.json({
      source: "origin",
      items: [
        { id: 1, name: "alpha" },
        { id: 2, name: "beta" },
      ],
    });
  }
});

app.use("/api", api);

// 404 padrão.
app.use((_req, res) => {
  res.status(404).json({ error: "not_found" });
});

const server = app.listen(config.port, () => {
  console.log(`cloudlab-backend ouvindo na porta ${config.port}`);
});

// Encerramento gracioso para rollout limpo no Kubernetes.
function shutdown(signal) {
  console.log(`Recebido ${signal}, encerrando...`);
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 10000).unref();
}
process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));

module.exports = app;
