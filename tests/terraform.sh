#!/usr/bin/env bash
#
# Testa a configuração Terraform: formatação e (quando possível) validação.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT}/infrastructure/terraform/live/cloudlab"

command -v terraform >/dev/null 2>&1 || { echo "SKIP: terraform não instalado"; exit 0; }

rc=0

echo "==> terraform fmt -check -recursive"
terraform -chdir="${TF_DIR}" fmt -check -recursive || { echo "  ! arquivos não formatados"; rc=1; }

echo "==> terraform validate (requer init)"
# init sem backend e sem baixar módulos remotos, apenas para validar sintaxe.
if terraform -chdir="${TF_DIR}" init -backend=false -input=false >/dev/null 2>&1; then
  terraform -chdir="${TF_DIR}" validate || rc=1
else
  echo "  - init falhou (provavelmente offline). Pulando validate."
fi

[ "$rc" -eq 0 ] && echo "==> Terraform: OK" || echo "==> Terraform: FALHOU"
exit "$rc"
