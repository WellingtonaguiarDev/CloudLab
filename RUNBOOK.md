# CloudLab — Passo a passo completo

Guia sequencial para levar o CloudLab **do zero ao ambiente rodando** na AWS: provisionar a infraestrutura, conectar ao cluster, instalar os componentes, implantar as aplicações e validar.

> Para uma referência mais curta, veja [docs/getting-started.md](./docs/getting-started.md). Para o detalhe de cada parte, veja [docs/](./docs/). Este documento é o walkthrough "faça na ordem".

---

## Índice

1. [Pré-requisitos](#1-pré-requisitos)
2. [Clonar e configurar](#2-clonar-e-configurar)
3. [(Opcional) Backend de state remoto](#3-opcional-backend-de-state-remoto)
4. [Provisionar a infraestrutura](#4-provisionar-a-infraestrutura)
5. [Conectar ao cluster EKS](#5-conectar-ao-cluster-eks)
6. [Instalar os add-ons do cluster](#6-instalar-os-add-ons-do-cluster)
7. [Aplicar segurança (namespaces, políticas, RBAC)](#7-aplicar-segurança)
8. [Instalar o monitoring](#8-instalar-o-monitoring)
9. [Construir e publicar as imagens](#9-construir-e-publicar-as-imagens)
10. [Implantar as aplicações](#10-implantar-as-aplicações)
11. [Validar o ambiente](#11-validar-o-ambiente)
12. [Rodar tudo local (sem AWS)](#12-rodar-tudo-local-sem-aws)
13. [Destruir o ambiente](#13-destruir-o-ambiente)
14. [Caveats conhecidos](#14-caveats-conhecidos)

---

## 1. Pré-requisitos

| Ferramenta | Versão | Verificar |
|---|---|---|
| AWS CLI | v2 | `aws --version` |
| Terraform | `~> 1.9` | `terraform version` |
| kubectl | compatível com EKS 1.33 | `kubectl version --client` |
| Helm | v3 | `helm version` |
| Docker | recente | `docker --version` |
| Node.js | 20+ | `node --version` |

Além disso:

- Uma conta AWS com permissão para criar VPC, EKS, ECS, RDS, ElastiCache, S3, ECR, KMS, IAM, ACM, Route53, ALB, EFS, CloudWatch e WAF.
- Credenciais AWS configuradas localmente (`aws configure` ou SSO). Região de trabalho: `us-east-1`.
- Um domínio real se quiser ACM/Route53 funcionando de verdade (o projeto usa `cloudlab.example.com` como placeholder).

Confira o acesso:

```bash
aws sts get-caller-identity
```

---

## 2. Clonar e configurar

```bash
git clone <URL-do-seu-repo> CloudLab
cd CloudLab
```

Ajuste os valores de exemplo antes de aplicar:

- **Domínio**: em `infrastructure/terraform/live/cloudlab/modules.tf`, troque `cloudlab.example.com` (módulos `acm` e `route53`) pelo seu domínio.
- **Variáveis**: `infrastructure/terraform/live/cloudlab/terraform.tfvars` já traz `region = "us-east-1"` e `environment = "production"`.

Validação rápida local (não toca em nada remoto):

```bash
chmod +x tools/*.sh tests/*.sh
tools/validate.sh
```

---

## 3. (Opcional) Backend de state remoto

Por padrão o Terraform usa **state local** (o backend S3 está comentado em `infrastructure/terraform/live/cloudlab/backend.tf`). Para trabalho em equipe/produção, use state remoto:

1. Provisione um bucket S3 (versionado) e uma tabela DynamoDB para lock — a pasta `infrastructure/bootstrap/` está reservada para isso.
2. Descomente e configure o bloco em `backend.tf`:

   ```hcl
   terraform {
     backend "s3" {
       bucket         = "SEU-BUCKET-STATE"
       key            = "cloudlab/terraform.tfstate"
       region         = "us-east-1"
       dynamodb_table = "SUA-TABELA-LOCK"
       encrypt        = true
     }
   }
   ```

3. Rode `terraform init -migrate-state`.

Se estiver só experimentando, pule esta etapa.

---

## 4. Provisionar a infraestrutura

```bash
cd infrastructure/terraform/live/cloudlab

terraform init
terraform fmt -check -recursive   # opcional, garante formatação
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Isso cria os 17 módulos (VPC, EKS, ECS, RDS, ElastiCache, S3, ECR, KMS, Secrets Manager, IAM/IRSA, ACM, Route53, ALB, EFS, CloudWatch, WAF, Security Groups). Leva alguns minutos, principalmente EKS e RDS.

Volte para a raiz depois:

```bash
cd ../../../..
```

---

## 5. Conectar ao cluster EKS

```bash
tools/kubeconfig.sh
# equivale a:
# aws eks update-kubeconfig --name cloudlab-eks --region us-east-1
kubectl get nodes
```

Você deve ver 2 nós `t3.medium` prontos.

---

## 6. Instalar os add-ons do cluster

Instale/aplique os componentes de `kubernetes/kube-system/`. Cada um usa a role IRSA criada pelo módulo `iam` — pegue os ARNs dos outputs do Terraform e anote nos `ServiceAccount`s correspondentes.

| Add-on | Função |
|---|---|
| AWS Load Balancer Controller | Provisiona o ALB via Ingress/Service |
| AWS EBS CSI Driver | StorageClass `gp3` (default) |
| AWS EFS CSI Driver | StorageClass `efs-sc` |
| Cluster Autoscaler | Escala o node group |
| Metrics Server | Habilita HPA e `kubectl top` |

Detalhes em [docs/operations.md](./docs/operations.md) e no runbook `runbooks/infrastructure.md`.

---

## 7. Aplicar segurança

```bash
kubectl apply -f security/pod-security/namespaces.yaml   # cria namespaces app/monitoring com PSS
kubectl apply -f security/network-policies/              # default-deny + liberações seletivas
kubectl apply -f security/rbac/roles.yaml                # developer, readonly, monitoring-viewer
```

Aplique os namespaces **antes** de implantar as aplicações e o monitoring.

---

## 8. Instalar o monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f monitoring/prometheus/values.yaml

# Alertas, ServiceMonitors e dashboard
kubectl apply -f monitoring/prometheus/alerts.yaml
kubectl apply -f monitoring/prometheus/servicemonitor.yaml
kubectl apply -f monitoring/grafana/dashboards/cloudlab.yaml
```

Acesse o Grafana via port-forward:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000  (dashboard "CloudLab Application")
```

---

## 9. Construir e publicar as imagens

No fluxo normal, o **CI faz isso automaticamente** ao dar push em `main` com mudanças em `applications/**` (ver [docs/deployment.md](./docs/deployment.md)). Para fazer manualmente:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR=${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
TAG=$(git rev-parse --short=8 HEAD)

aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$ECR"

docker build -t "$ECR/backend:$TAG"  applications/backend
docker build -t "$ECR/frontend:$TAG" applications/frontend
docker push "$ECR/backend:$TAG"
docker push "$ECR/frontend:$TAG"
```

Os repositórios ECR (`backend`, `frontend`) são criados pelo Terraform.

---

## 10. Implantar as aplicações

Fluxo padrão: o **CD** implanta via Helm quando o CI conclui com sucesso. Para deploy manual:

```bash
export ECR_REGISTRY="$ECR"     # do passo anterior
tools/deploy.sh "$TAG"
```

O script roda, no namespace `app`:

```bash
helm upgrade --install cloudlab-backend  helm-charts/backend  --set image.repository=$ECR/backend  --set image.tag=$TAG  --atomic --timeout 5m
helm upgrade --install cloudlab-frontend helm-charts/frontend --set image.repository=$ECR/frontend --set image.tag=$TAG --atomic --timeout 5m
```

> Os nomes de release `cloudlab-backend`/`cloudlab-frontend` geram os deployments de mesmo nome (`cloudlab-backend`/`cloudlab-frontend`).

Para o backend funcionar de verdade, ele precisa das credenciais do RDS no secret `cloudlab-rds` (ver [caveats](#14-caveats-conhecidos)) e dos endpoints via `--set env.DB_HOST=...` / `env.REDIS_HOST=...`.

---

## 11. Validar o ambiente

```bash
# Pods e rollout
kubectl get pods -n app
kubectl rollout status deployment/cloudlab-backend  -n app --timeout=3m
kubectl rollout status deployment/cloudlab-frontend -n app --timeout=3m

# Autoscaling
kubectl get hpa -n app

# Health interno do backend
kubectl -n app port-forward deployment/cloudlab-backend 8080:8080
curl localhost:8080/health
curl localhost:8080/api/items
```

Acesso externo: pegue o DNS do ALB (output do Terraform ou o Ingress) e acesse via HTTPS. Com Route53/ACM configurados, use o domínio.

Rode a suíte de validação a qualquer momento:

```bash
tests/run-all.sh
```

---

## 12. Rodar tudo local (sem AWS)

Para testar as aplicações sem provisionar nada na nuvem:

```bash
# Backend
cd applications/backend
npm install
npm start           # http://localhost:8080/health  ·  /api/items  ·  /metrics
```

```bash
# Frontend (em outro terminal)
cd applications/frontend
npm install
npm run dev         # http://localhost:5173  (proxy /api -> localhost:8080)
```

Sem MySQL/Redis locais, `/health` responde `200` com `database`/`cache` como `down` — comportamento esperado.

---

## 13. Destruir o ambiente

```bash
# Remova primeiro as apps e o monitoring do cluster
helm uninstall cloudlab-backend cloudlab-frontend -n app
helm uninstall kube-prometheus-stack -n monitoring

# Depois a infraestrutura
cd infrastructure/terraform/live/cloudlab
terraform destroy
```

> ⚠️ `terraform destroy` remove **todos** os recursos, incluindo RDS, S3 e EFS. Operação destrutiva e irreversível — confirme backups antes.

---

## 14. Caveats conhecidos

Pontos que você provavelmente vai precisar ajustar para um ambiente 100% funcional:

1. **Senha do RDS no Secrets Manager**: o módulo `rds` gera a senha via `random_password`, mas o módulo `secrets-manager` (em `modules.tf`) grava apenas `engine/host/port/dbname/username` no secret `cloudlab/rds` — **sem a chave `password`**. O backend, porém, espera `username` e `password` (`envFromSecrets` no chart). Para fechar isso, faça o módulo `rds` expor a senha (output) e inclua-a no `secret_data` do `secrets-manager`. Trate esse output como sensível (`sensitive = true`).

2. **Nome do secret**: o Terraform cria `cloudlab/rds`; o chart referencia `cloudlab-rds` (`envFromSecrets.secretName`). Alinhe os dois — ou o nome do secret no AWS, ou o valor no `values.yaml`.

3. **Domínio de exemplo**: `cloudlab.example.com` está em ACM e Route53. Sem um domínio real e uma hosted zone válida, a validação do certificado não conclui.

4. **State local**: enquanto o backend S3 estiver comentado, o `terraform.tfstate` fica no seu disco. Não versione esse arquivo (já coberto pelo `.gitignore`).

5. **Métricas do frontend**: o `/metrics` do frontend é um stub (nginx não expõe métricas Prometheus nativas). Para métricas reais, adicione um sidecar `nginx-prometheus-exporter`.

6. **Push vs GitOps**: o deploy padrão é push-based (`cicd/cd.yaml`). Há um esqueleto GitOps (Argo CD) em `platform/gitops/`. Não use os dois para o mesmo recurso ao mesmo tempo.
