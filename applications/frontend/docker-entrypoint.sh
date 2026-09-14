#!/bin/sh
set -e

# Injeta a URL da API em runtime (env API_URL, definida pelo Helm chart).
# Assim a mesma imagem serve para qualquer ambiente sem rebuild.
API_URL="${API_URL:-/api}"
HTML_DIR="/usr/share/nginx/html"
CONFIG_FILE="${HTML_DIR}/config.js"
INDEX_FILE="${HTML_DIR}/index.html"

# Gera o config.js consumido pelo bundle (window.__API_URL__).
echo "window.__API_URL__ = \"${API_URL}\";" > "$CONFIG_FILE"

# Garante que o index.html carregue o config.js ANTES do bundle da aplicação.
# O Vite remove scripts externos não-módulo do build, então reinjetamos aqui.
if ! grep -q 'src="/config.js"' "$INDEX_FILE"; then
  sed -i 's#<div id="root"></div>#<div id="root"></div><script src="/config.js"></script>#' "$INDEX_FILE"
fi

echo "Frontend configurado com API_URL=${API_URL}"

exec "$@"
