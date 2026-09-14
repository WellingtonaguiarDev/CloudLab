#!/usr/bin/env bash
#
# Testa os Helm charts: lint + template renderiza sem erro.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v helm >/dev/null 2>&1 || { echo "SKIP: helm não instalado"; exit 0; }

rc=0
for chart in "${ROOT}/helm-charts/backend" "${ROOT}/helm-charts/frontend"; do
  name="$(basename "$chart")"
  echo "==> [${name}] helm lint"
  helm lint "$chart" || rc=1

  echo "==> [${name}] helm template"
  helm template test "$chart" \
    --set image.repository=example/repo \
    --set image.tag=test >/dev/null || rc=1
done

[ "$rc" -eq 0 ] && echo "==> Helm: OK" || echo "==> Helm: FALHOU"
exit "$rc"
