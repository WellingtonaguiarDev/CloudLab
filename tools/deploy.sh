#!/usr/bin/env bash
#
# Deploy manual dos charts backend e frontend via Helm.
# Uso: tools/deploy.sh <image-tag>
#
# Requer ECR_REGISTRY definido (ex: 123456789012.dkr.ecr.us-east-1.amazonaws.com).
# Este é um fallback manual; o caminho padrão é o pipeline de CD (cicd/).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${NAMESPACE:-app}"
TAG="${1:-}"

if [ -z "${TAG}" ]; then
  echo "Uso: tools/deploy.sh <image-tag>"
  exit 1
fi
if [ -z "${ECR_REGISTRY:-}" ]; then
  echo "Defina ECR_REGISTRY (ex: <account>.dkr.ecr.us-east-1.amazonaws.com)"
  exit 1
fi

command -v helm >/dev/null 2>&1 || { echo "helm não encontrado"; exit 1; }

echo "==> Deploy backend (tag ${TAG})"
helm upgrade --install cloudlab-backend "${ROOT}/helm-charts/backend" \
  --namespace "${NAMESPACE}" --create-namespace \
  --set image.repository="${ECR_REGISTRY}/backend" \
  --set image.tag="${TAG}" \
  --atomic --timeout 5m

echo "==> Deploy frontend (tag ${TAG})"
helm upgrade --install cloudlab-frontend "${ROOT}/helm-charts/frontend" \
  --namespace "${NAMESPACE}" --create-namespace \
  --set image.repository="${ECR_REGISTRY}/frontend" \
  --set image.tag="${TAG}" \
  --atomic --timeout 5m

echo "==> Verificando rollout"
kubectl rollout status deployment/cloudlab-backend -n "${NAMESPACE}" --timeout=3m || true
kubectl rollout status deployment/cloudlab-frontend -n "${NAMESPACE}" --timeout=3m || true
echo "==> Concluído"
