# Runbook: Deploy

## Fluxo normal (CI/CD automático)

1. Push para `main` → CI builda e faz push das imagens no ECR
2. CD é triggerado automaticamente após CI com sucesso
3. Helm faz upgrade com `--atomic` → rollback automático se falhar
4. `kubectl rollout status` confirma que os pods subiram

## Deploy manual (emergência)

```bash
# Configurar kubeconfig
aws eks update-kubeconfig --name cloudlab-eks --region us-east-1

# Login no ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Deploy backend
helm upgrade --install backend helm-charts/backend \
  --namespace app \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/backend \
  --set image.tag=<TAG> \
  --atomic --timeout 5m

# Deploy frontend
helm upgrade --install frontend helm-charts/frontend \
  --namespace app \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/frontend \
  --set image.tag=<TAG> \
  --atomic --timeout 5m
```

## Verificar status do deploy

```bash
kubectl get pods -n app
kubectl rollout status deployment/cloudlab-backend -n app
kubectl rollout status deployment/cloudlab-frontend -n app
```

## Rollback manual

```bash
# Ver histórico
helm history backend -n app

# Rollback para revisão anterior
helm rollback backend <REVISION> -n app --wait
```
