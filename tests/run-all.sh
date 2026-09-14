#!/usr/bin/env bash
#
# Executa todos os testes e agrega o resultado.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rc=0

for t in terraform.sh helm.sh backend-smoke.sh; do
  echo ""
  echo "############################################"
  echo "# ${t}"
  echo "############################################"
  bash "${DIR}/${t}" || rc=1
done

echo ""
if [ "$rc" -eq 0 ]; then
  echo "==> TODOS OS TESTES PASSARAM"
else
  echo "==> ALGUNS TESTES FALHARAM"
fi
exit "$rc"
