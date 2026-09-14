#!/usr/bin/env bash
#
# Smoke test do backend: instala deps, sobe o servidor e valida os endpoints
# e as métricas exigidas pela plataforma (label app="backend").
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${ROOT}/applications/backend"
PORT="${PORT:-8080}"

command -v node >/dev/null 2>&1 || { echo "SKIP: node não instalado"; exit 0; }
command -v curl >/dev/null 2>&1 || { echo "SKIP: curl não instalado"; exit 0; }

cd "${APP_DIR}"

if [ ! -d node_modules ]; then
  echo "==> Instalando dependências"
  npm install --no-audit --no-fund >/dev/null 2>&1
fi

echo "==> Subindo backend na porta ${PORT}"
PORT="${PORT}" node src/server.js &
PID=$!
# Garante o encerramento do servidor ao sair do script.
trap 'kill "${PID}" 2>/dev/null || true' EXIT

# Espera o servidor responder (até ~10s).
for _ in $(seq 1 20); do
  curl -sf "http://localhost:${PORT}/health" >/dev/null 2>&1 && break
  sleep 0.5
done

rc=0
check() { # check <descrição> <comando...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  ok   ${desc}"
  else
    echo "  FAIL ${desc}"; rc=1
  fi
}

echo "==> Verificações"
check "GET /health responde 200"  curl -sf "http://localhost:${PORT}/health"
check "GET /api/items responde"    curl -sf "http://localhost:${PORT}/api/items"
check "/metrics expõe http_requests_total com app=backend" \
  bash -c "curl -sf http://localhost:${PORT}/metrics | grep -q 'http_requests_total{.*app=\"backend\"'"
check "/metrics expõe histograma de latência" \
  bash -c "curl -sf http://localhost:${PORT}/metrics | grep -q 'http_request_duration_seconds_bucket'"

[ "$rc" -eq 0 ] && echo "==> Backend smoke: OK" || echo "==> Backend smoke: FALHOU"
exit "$rc"
