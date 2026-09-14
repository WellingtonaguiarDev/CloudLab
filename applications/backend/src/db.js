"use strict";

const mysql = require("mysql2/promise");
const Redis = require("ioredis");

const config = require("./config");

let pool;
let redis;

// Lazy: só cria o pool MySQL na primeira chamada, e reaproveita depois.
function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: config.db.host,
      port: config.db.port,
      user: config.db.user,
      password: config.db.password,
      database: config.db.name,
      waitForConnections: true,
      connectionLimit: 10,
      maxIdle: 10,
      idleTimeout: 60000,
      enableKeepAlive: true,
    });
  }
  return pool;
}

function getRedis() {
  if (!redis) {
    redis = new Redis({
      host: config.redis.host,
      port: config.redis.port,
      lazyConnect: true,
      maxRetriesPerRequest: 1,
      // Em ambiente sem Redis (dev local), evita crash por reconexão infinita.
      retryStrategy: (times) => (times > 3 ? null : Math.min(times * 200, 1000)),
    });
    redis.on("error", () => {
      /* silencioso: o /health reporta o estado */
    });
  }
  return redis;
}

// Verifica conectividade. Não lança — retorna o estado de cada dependência.
async function checkHealth() {
  const result = { database: "unknown", cache: "unknown" };

  try {
    const conn = await getPool().getConnection();
    await conn.ping();
    conn.release();
    result.database = "up";
  } catch (err) {
    result.database = "down";
  }

  try {
    const r = getRedis();
    if (r.status !== "ready" && r.status !== "connecting") {
      await r.connect();
    }
    await r.ping();
    result.cache = "up";
  } catch (err) {
    result.cache = "down";
  }

  return result;
}

module.exports = { getPool, getRedis, checkHealth };
