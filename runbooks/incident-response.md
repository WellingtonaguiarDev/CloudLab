# Runbook: Resposta a Incidentes

## BackendHighErrorRate (5xx > 5%)

**Severidade:** Critical

```bash
# 1. Ver pods com erro
kubectl get pods -n app
kubectl logs -l app.kubernetes.io/name=backend -n app --tail=50

# 2. Checar eventos recentes
kubectl get events -n app --sort-by='.lastTimestamp' | tail -20

# 3. Checar métricas no Grafana
# Dashboard: CloudLab Application → Error Rate

# 4. Se necessário, rollback
helm rollback backend -n app --wait
```

---

## BackendHighLatency (p99 > 2s)

**Severidade:** Warning

```bash
# 1. Checar uso de CPU/memória
kubectl top pods -n app

# 2. Checar conexões com RDS
kubectl exec -it <POD_NAME> -n app -- curl localhost:8080/metrics | grep db_

# 3. Checar slow queries no RDS via CloudWatch
aws logs filter-log-events \
  --log-group-name /cloudlab/rds \
  --filter-pattern "Query_time" \
  --region us-east-1

# 4. Se CPU alta, HPA pode estar no limite — escalar manualmente
kubectl scale deployment cloudlab-backend --replicas=4 -n app
```

---

## PodCrashLooping

**Severidade:** Critical

```bash
# Ver runbook: troubleshooting-pods.md → "Pod em CrashLoopBackOff"

# Isolar pod problemático (cordon do node se necessário)
kubectl cordon <NODE_NAME>
kubectl drain <NODE_NAME> --ignore-daemonsets --delete-emptydir-data
```

---

## RDS CPU High (> 80%)

**Severidade:** Warning

```bash
# Ver queries ativas via CloudWatch Logs Insights
aws logs start-query \
  --log-group-name /cloudlab/rds \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /Query_time/ | sort Query_time desc | limit 20' \
  --region us-east-1
```

---

## RDS Storage Low (< 5GB)

**Severidade:** Warning

```bash
# Verificar uso atual
aws rds describe-db-instances \
  --db-instance-identifier cloudlab-mysql \
  --query 'DBInstances[0].AllocatedStorage' \
  --region us-east-1

# Aumentar storage (autoscaling já configurado até 100GB)
# Se necessário forçar manualmente:
aws rds modify-db-instance \
  --db-instance-identifier cloudlab-mysql \
  --allocated-storage 50 \
  --apply-immediately \
  --region us-east-1
```
