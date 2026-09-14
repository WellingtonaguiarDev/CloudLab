"use strict";

// Configuração via variáveis de ambiente. Os nomes batem com os injetados
// pelo Helm chart (helm-charts/backend/values.yaml) e pelo pipeline de CD.
module.exports = {
  port: parseInt(process.env.PORT || "8080", 10),
  db: {
    host: process.env.DB_HOST || "localhost",
    port: parseInt(process.env.DB_PORT || "3306", 10),
    name: process.env.DB_NAME || "cloudlab",
    // USERNAME/PASSWORD vêm do secret cloudlab-rds (envFromSecrets no chart).
    user: process.env.USERNAME || process.env.DB_USER || "root",
    password: process.env.PASSWORD || process.env.DB_PASSWORD || "",
  },
  redis: {
    host: process.env.REDIS_HOST || "localhost",
    port: parseInt(process.env.REDIS_PORT || "6379", 10),
  },
};
