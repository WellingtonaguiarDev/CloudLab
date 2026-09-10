# Runbook: Troubleshooting de Pods

## Pod em CrashLoopBackOff

```bash
# Ver eventos do pod
kubectl describe pod <POD_NAME> -n app

# Ver logs do container atual
kubectl logs <POD_NAME> -n app

# Ver logs do container anterior (antes do crash)
kubectl logs <POD_NAME> -n app --previous

# Ver últimas 100 linhas
kubectl logs <POD_NAME> -n app --tail=100
```

**Causas comuns:**
- Variável de ambiente faltando → checar `kubectl describe pod` em `Environment`
- Falha no health check → checar `livenessProbe` e `readinessProbe`
- OOMKilled → aumentar `resources.limits.memory` no values.yaml
- Erro de conexão com RDS/Redis → checar NetworkPolicy e Security Groups

## Pod em Pending

```bash
kubectl describe pod <POD_NAME> -n app
```

**Causas comuns:**
- Sem nodes disponíveis → checar Cluster Autoscaler: `kubectl logs -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler`
- PVC não bound → `kubectl get pvc -n app`
- Recursos insuficientes → `kubectl describe nodes`

## Pod não passa no readiness

```bash
# Testar endpoint de health manualmente
kubectl exec -it <POD_NAME> -n app -- curl localhost:8080/health

# Port-forward para testar localmente
kubectl port-forward pod/<POD_NAME> 8080:8080 -n app
curl localhost:8080/health
```

## Verificar conectividade com RDS

```bash
kubectl run debug --rm -it --image=mysql:8.4 -n app -- \
  mysql -h <RDS_ENDPOINT> -u admin -p cloudlab
```

## Verificar conectividade com Redis

```bash
kubectl run debug --rm -it --image=redis:7 -n app -- \
  redis-cli -h <REDIS_ENDPOINT> -p 6379 ping
```
