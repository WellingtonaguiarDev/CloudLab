"use strict";

const client = require("prom-client");

// Registro dedicado da aplicação.
const register = new client.Registry();

// Label "app" fixo em "backend" — é o label consultado pelos alertas
// (monitoring/prometheus/alerts.yaml) e pelo dashboard do Grafana.
register.setDefaultLabels({ app: "backend" });

// Métricas padrão do Node (process/heap/event loop).
client.collectDefaultMetrics({ register });

// Contador de requisições HTTP. Nome e labels alinhados com o dashboard
// (http_requests_total{namespace,app,status}).
const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total de requisições HTTP recebidas",
  labelNames: ["method", "route", "status"],
  registers: [register],
});

// Histograma de latência. Nome alinhado com o alerta de p99
// (http_request_duration_seconds_bucket).
const httpRequestDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "Duração das requisições HTTP em segundos",
  labelNames: ["method", "route", "status"],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5],
  registers: [register],
});

// Middleware Express que mede cada requisição.
function metricsMiddleware(req, res, next) {
  const end = httpRequestDuration.startTimer();
  res.on("finish", () => {
    // Usa a rota registrada (ex: "/api/items/:id") para evitar cardinalidade alta.
    const route = req.route ? req.baseUrl + req.route.path : req.path;
    const labels = {
      method: req.method,
      route,
      status: String(res.statusCode),
    };
    httpRequestsTotal.inc(labels);
    end(labels);
  });
  next();
}

// Handler do endpoint /metrics.
async function metricsHandler(_req, res) {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
}

module.exports = { register, metricsMiddleware, metricsHandler };
