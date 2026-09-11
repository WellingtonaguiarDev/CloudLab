# Operações

Este documento cobre observabilidade, segurança de runtime, add-ons do cluster e os runbooks operacionais do CloudLab.

## Add-ons do cluster (kube-system)

Manifests em `kubernetes/kube-system/`. Cada add-on tem uma role IRSA correspondente criada pelo módulo `iam` (ver [infrastructure.md](./infrastructure.md)).

| Add-on | Função |
|---|---|
| `aws-load-balancer-controller` | Provisiona ALB/NLB a partir de recursos Ingress/Service |
| `aws-ebs-csi-driver` | StorageClass `gp3` criptografada (default) para volumes de bloco |
| `aws-efs-csi-driver` | StorageClass `efs-sc` com access point para storage compartilhado |
| `cluster-autoscaler` | Escala o node group automaticamente conforme a demanda |
| `metrics-server` | Fornece métricas para HPA e `kubectl top` |

## Monitoring

Configuração em `monitoring/`.

### Prometheus (`monitoring/prometheus/`)

- `values.yaml`: valores do chart **kube-prometheus-stack** (Prometheus + Alertmanager + node-exporter + kube-state-metrics + Grafana).
- Retenção: **15 dias / 10 GB**, com PVC em StorageClass `gp3`.
- `servicemonitor.yaml`: define scrape das aplicações.
- `alerts.yaml`: `PrometheusRule` customizado com os alertas do projeto.

### Grafana (`monitoring/grafana/dashboards/`)

- `cloudlab.yaml`: dashboard da aplicação com Request Rate, Error Rate, Latência p99, CPU e memória.

### Alertas configurados

| Alerta | Condição | Severidade |
|---|---|---|
| BackendHighErrorRate | 5xx > 5% por 5 min | Critical |
| BackendHighLatency | p99 > 2s por 5 min | Warning |
| PodCrashLooping | > 3 restarts em 15 min | Critical |
| PodNotReady | Pod não-ready por 5 min | Warning |
| RDS CPU High | CPU > 80% | Warning |
| RDS Storage Low | Storage livre < 5 GB | Warning |
| ECS CPU High | CPU > 80% | Warning |
| ALB 5xx High | Erros 5xx > 10 | Warning |

Além do Prometheus, o módulo Terraform `cloudwatch` provisiona log groups, alarmes (RDS/ECS/ALB) e um dashboard no CloudWatch.

## Security

Configuração em `security/`.

### NetworkPolicies (`security/network-policies/`)

- `app.yaml` e `monitoring.yaml`: modelo **default-deny-all** com liberação seletiva por porta e seletor. Só o tráfego explicitamente permitido flui entre os namespaces `app` e `monitoring`.

### Pod Security Standards (`security/pod-security/namespaces.yaml`)

| Namespace | Nível PSS |
|---|---|
| `app` | `restricted` |
| `monitoring` | `baseline` |

### RBAC (`security/rbac/roles.yaml`)

| Role | Escopo |
|---|---|
| `developer` | Acesso de desenvolvimento aos recursos da aplicação |
| `readonly` | Somente leitura |
| `monitoring-viewer` | Visualização do stack de observabilidade |

### Controles adicionais

| Controle | Detalhe |
|---|---|
| IRSA | Todos os workloads e controllers usam roles IAM via OIDC |
| WAF | CommonRuleSet + SQLi + KnownBadInputs + rate limit 2000 req/5min |
| KMS | Rotação automática em todas as chaves |
| Secrets | Zero credenciais em código — tudo via Secrets Manager |
| TLS | ALB com TLS 1.3 e redirect HTTP→HTTPS |
| ECR | Tag immutability + scan on push |

O arquivo `security/checklist.md` reúne o checklist de segurança do ambiente.

## Runbooks

Procedimentos operacionais em `runbooks/`.

| Runbook | Conteúdo |
|---|---|
| `deploy.md` | Fluxo de CI/CD, deploy manual e rollback |
| `troubleshooting-pods.md` | CrashLoop, Pending, health checks e conectividade |
| `incident-response.md` | Resposta a cada alerta do Prometheus |
| `infrastructure.md` | Terraform, kubeconfig, instalação de add-ons via Helm, Grafana |

## Verificações rápidas

```bash
# Status dos nós e pods
kubectl get nodes
kubectl get pods -n app
kubectl get pods -n kube-system

# Métricas (requer metrics-server)
kubectl top pods -n app

# Rollout das aplicações
kubectl rollout status deployment/cloudlab-backend -n app
kubectl rollout status deployment/cloudlab-frontend -n app

# HPA
kubectl get hpa -n app
```
