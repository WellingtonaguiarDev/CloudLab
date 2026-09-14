#!/usr/bin/env bash
#
# Valida a infraestrutura e os charts localmente, sem tocar em nada remoto.
# Uso: tools/validate.sh
set -euo pipefail

# Raiz do repositório (este script fica em tools/).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT}/infrastructure/terraform/live/cloudlab"

fail=0

echo "==> Terraform fmt (check)"
if command -v terraform >/dev/null 2>&1; then
  terraform -chdir="${TF_DIR}" fmt -check -recursive || { echo "  ! terraform fmt encontrou arquivos não formatados"; fail=1; }
else
  echo "  - terraform não instalado, pulando"
fi

echo "==> Helm lint + template"
if command -v helm >/dev/null 2>&1; then
  for chart in "${ROOT}/helm-charts/backend" "${ROOT}/helm-charts/frontend"; do
    echo "  - $(basename "$chart")"
    helm lint "$chart" || fail=1
    # template com valores mínimos para detectar erros de renderização.
    helm template test "$chart" \
      --set image.repository=example/repo \
      --set image.tag=test >/dev/null || fail=1
  done
else
  echo "  - helm não instalado, pulando"
fi

if [ "$fail" -ne 0 ]; then
  echo "==> Validação FALHOU"
  exit 1
fi
echo "==> Validação OK"
