# Getting Started

Guia para provisionar a infraestrutura do CloudLab e implantar as aplicações do zero. Para o detalhe de cada peça, consulte [infrastructure.md](./infrastructure.md), [deployment.md](./deployment.md) e [operations.md](./operations.md).

## Pré-requisitos

### Ferramentas locais

| Ferramenta | Versão recomendada | Uso |
|---|---|---|
| AWS CLI | v2 | Autenticação e `update-kubeconfig` |
| Terraform | `~> 1.9` | Provisionar a infraestrutura |
| kubectl | compatível com EKS 1.33 | Operar o cluster |
| Helm | v3 | Implantar os charts |
| Docker | recente | Build das imagens (backend/frontend) |

### Conta AWS

- Uma conta AWS com permissão para criar VPC, EKS, ECS, RDS, ElastiCache, S3, ECR, KMS, IAM, ACM, Route53, ALB, EFS, CloudWatch e WAF.
- Região de trabalho: `us-east-1`.
- Um domínio válido caso queira ACM/Route53 reais (o projeto usa `cloudlab.example.com` como placeholder — ajuste em `infrastructure/terraform/live/cloudlab/modules.tf`).

## Passo 1 — Provisionar a infraestrutura

```bash
cd infrastructure/terraform/live/cloudlab

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Variáveis padrão (`terraform.tfvars`): `region = "us-east-1"`, `environment = "production"`.

> **State**: o backend S3 está comentado em `backend.tf`, então o state é local. Para trabalho em equipe, habilite o backend S3 (com lock via DynamoDB) usando os recursos previstos em `infrastructure/bootstrap/`.

## Passo 2 — Conectar ao cluster EKS

```bash
aws eks update-kubeconfig --name cloudlab-eks --region us-east-1
kubectl get nodes
```

## Passo 3 — Instalar os add-ons do cluster

Aplique/instale os componentes de `kubernetes/kube-system/` (AWS Load Balancer Controller, EBS CSI, EFS CSI, Cluster Autoscaler, Metrics Server). Cada um usa a role IRSA criada pelo módulo `iam`. Detalhes em [operations.md](./operations.md) e no runbook `runbooks/infrastructure.md`.

## Passo 4 — Instalar o monitoring

Instale o stack de observabilidade a partir de `monitoring/prometheus/values.yaml` (kube-prometheus-stack) e importe o dashboard `monitoring/grafana/dashboards/cloudlab.yaml`. As regras de alerta ficam em `monitoring/prometheus/alerts.yaml`.

## Passo 5 — Aplicar as políticas de segurança

Aplique os manifests de `security/`:

```bash
kubectl apply -f security/pod-security/namespaces.yaml
kubectl apply -f security/network-policies/
kubectl apply -f security/rbac/roles.yaml
```

## Passo 6 — Implantar as aplicações

O caminho recomendado é via **CI/CD** (push em `main`), que faz build/push no ECR e `helm upgrade` no EKS. Consulte [deployment.md](./deployment.md) para os secrets de pipeline necessários.

Para deploy manual:

```bash
helm upgrade --install backend helm-charts/backend \
  --namespace app --create-namespace \
  --set image.repository=<account>.dkr.ecr.us-east-1.amazonaws.com/backend \
  --set image.tag=<tag> \
  --atomic --timeout 5m

helm upgrade --install frontend helm-charts/frontend \
  --namespace app --create-namespace \
  --set image.repository=<account>.dkr.ecr.us-east-1.amazonaws.com/frontend \
  --set image.tag=<tag> \
  --atomic --timeout 5m
```

## Passo 7 — Verificar

```bash
kubectl get pods -n app
kubectl rollout status deployment/cloudlab-backend -n app
kubectl rollout status deployment/cloudlab-frontend -n app
kubectl get hpa -n app
```

## Destruir o ambiente

```bash
cd infrastructure/terraform/live/cloudlab
terraform destroy
```

> ⚠️ `terraform destroy` remove todos os recursos AWS provisionados, incluindo RDS, S3 e EFS. É uma operação destrutiva e irreversível — confirme backups antes de executar.

## Próximos passos

- As aplicações de exemplo já existem em `applications/backend` (Node/Express) e `applications/frontend` (React/nginx) — ver [applications.md](./applications.md). Substitua a lógica de negócio conforme a necessidade real.
- Substituir o domínio de exemplo `cloudlab.example.com` por um domínio real.
- Habilitar o backend de state remoto (S3 + DynamoDB).
