#!/usr/bin/env bash
#
# Scaffolding de um novo serviço a partir do golden path Node.
# Uso: tools/new-service.sh <nome> <porta>
#   ex: tools/new-service.sh orders 8080
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${ROOT}/platform/golden-paths/service-node"

NAME="${1:-}"
PORT="${2:-8080}"

if [ -z "${NAME}" ]; then
  echo "Uso: tools/new-service.sh <nome> <porta>"
  exit 1
fi
if [ ! -d "${TEMPLATE}" ]; then
  echo "Template não encontrado em ${TEMPLATE}"
  exit 1
fi

DEST="${ROOT}/applications/${NAME}"
if [ -e "${DEST}" ]; then
  echo "Destino já existe: ${DEST}"
  exit 1
fi

echo "==> Criando serviço '${NAME}' (porta ${PORT}) em applications/${NAME}"
mkdir -p "${DEST}/src"

# Copia os templates removendo o sufixo .tmpl e substituindo os placeholders.
render() {
  sed -e "s/__SERVICE_NAME__/${NAME}/g" -e "s/__PORT__/${PORT}/g" "$1" > "$2"
}

render "${TEMPLATE}/package.json.tmpl" "${DEST}/package.json"
render "${TEMPLATE}/src/server.js.tmpl" "${DEST}/src/server.js"

cat > "${DEST}/README.md" <<EOF
# ${NAME}

Serviço gerado a partir do golden path Node (platform/golden-paths/service-node).

- Porta: ${PORT}
- Endpoints: \`GET /health\`, \`GET /metrics\`, \`GET /api\`

## Próximos passos
1. Adicionar um Dockerfile (base: applications/backend/Dockerfile).
2. Criar o Helm chart (base: helm-charts/backend).
3. Registrar no catálogo (platform/catalog/).
EOF

echo "==> Pronto. Estrutura criada:"
find "${DEST}" -type f | sed "s#${ROOT}/##"
echo "==> Lembre-se de: Dockerfile, Helm chart e entrada no catálogo."
