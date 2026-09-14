#!/usr/bin/env bash
#
# Atualiza o kubeconfig local para o cluster EKS do CloudLab.
# Uso: tools/kubeconfig.sh
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
EKS_CLUSTER="${EKS_CLUSTER:-cloudlab-eks}"

command -v aws >/dev/null 2>&1     || { echo "aws CLI não encontrado"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl não encontrado"; exit 1; }

echo "==> Atualizando kubeconfig para ${EKS_CLUSTER} (${AWS_REGION})"
aws eks update-kubeconfig --name "${EKS_CLUSTER}" --region "${AWS_REGION}"

echo "==> Contexto atual:"
kubectl config current-context

echo "==> Nós:"
kubectl get nodes
