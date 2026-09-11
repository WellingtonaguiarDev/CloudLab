# Deploy (Helm + CI/CD)

As aplicações do CloudLab são empacotadas em charts Helm e implantadas no EKS através de pipelines do GitHub Actions com autenticação OIDC (sem chaves de acesso estáticas).

## Helm charts

Os charts ficam em `helm-charts/backend` e `helm-charts/frontend`. Ambos seguem a mesma estrutura:

```
helm-charts/<app>/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    ├── serviceaccount.yaml
    ├── hpa.yaml
    └── pdb.yaml
```

Chart backend (`Chart.yaml`): `apiVersion: v2`, `name: backend`, `type: application`, `version: 0.1.0`, `appVersion: 1.0.0`.

### Backend

Valores relevantes (`helm-charts/backend/values.yaml`):

| Configuração | Valor |
|---|---|
| Namespace de destino | `app` |
| replicaCount | 2 |
| Service | `ClusterIP`, porta `8080` |
| Recursos (requests) | CPU `100m`, memória `128Mi` |
| Recursos (limits) | CPU `500m`, memória `512Mi` |
| Autoscaling (HPA) | min 2 / max 6, alvo CPU 70% |
| ServiceAccount | `backend` (criado), anotação IRSA `eks.amazonaws.com/role-arn` |
| Liveness/Readiness | `GET /health` na porta 8080 |
| Env | `DB_HOST`, `DB_PORT=3306`, `DB_NAME=cloudlab`, `REDIS_HOST`, `REDIS_PORT=6379` |
| Secrets | `cloudlab-rds` → chaves `username`, `password` |
| topologySpreadConstraints | habilitado (distribui entre AZs) |
| PodDisruptionBudget | habilitado, `minAvailable: 1` |
| Ingress | desabilitado (tráfego chega via ALB externo) |

### Frontend

Valores relevantes (`helm-charts/frontend/values.yaml`):

| Configuração | Valor |
|---|---|
| Namespace de destino | `app` |
| replicaCount | 2 |
| Service | `ClusterIP`, porta `80` |
| Recursos (requests) | CPU `50m`, memória `64Mi` |
| Recursos (limits) | CPU `200m`, memória `256Mi` |
| Autoscaling (HPA) | min 2 / max 4, alvo CPU 70% |
| ServiceAccount | `frontend` (criado, sem IRSA por padrão) |
| Liveness/Readiness | `GET /` na porta 80 |
| Env | `API_URL` |
| topologySpreadConstraints | habilitado |
| PodDisruptionBudget | habilitado, `minAvailable: 1` |

> `image.repository` fica vazio no `values.yaml` e é preenchido em tempo de deploy pelo pipeline com o endereço do ECR e a tag da imagem.

## Pipelines de CI/CD

Os workflows ficam em `cicd/.github/workflows/`. Todos usam OIDC (`aws-actions/configure-aws-credentials@v4` com `role-to-assume: secrets.AWS_ROLE_ARN`), região `us-east-1`.

### CI — `ci.yaml`

- **Gatilho**: push/PR em `main` com mudanças em `applications/**`.
- **Jobs** (`backend` e `frontend`, em paralelo):
  1. Checkout e login no ECR (`amazon-ecr-login@v2`).
  2. Define a tag da imagem como os 8 primeiros caracteres do SHA (`${GITHUB_SHA::8}`).
  3. `docker/build-push-action@v5` faz build a partir de `applications/backend` ou `applications/frontend` e push para o ECR.
  4. Push só ocorre quando o ref é `main`. Tags aplicadas: `<sha8>` e `latest`, com cache inline via ECR.

### CD — `cd.yaml`

- **Gatilho**: `workflow_run` do CI concluído com sucesso em `main`.
- **Job** `deploy` (roda só se `conclusion == 'success'`):
  1. Configura OIDC e atualiza o kubeconfig do cluster `cloudlab-eks`.
  2. Recalcula a tag (`${GITHUB_SHA::8}`).
  3. `helm upgrade --install backend` no namespace `app`, com `image.repository`/`image.tag`, anotação IRSA, `env.DB_HOST` e `env.REDIS_HOST` (via secrets), `--atomic --timeout 5m`.
  4. `helm upgrade --install frontend` no namespace `app`, com imagem e `env.API_URL=https://cloudlab.example.com/api`, `--atomic --timeout 5m`.
  5. Verifica o rollout: `kubectl rollout status deployment/cloudlab-backend` e `deployment/cloudlab-frontend` (timeout 3m).

`--atomic` garante **rollback automático** se o upgrade falhar.

### Terraform — `terraform.yaml`

- **Gatilho**: push/PR em `main` com mudanças em `infrastructure/terraform/**`.
- **Job `plan`** (roda sempre): `init`, `validate`, `plan -out=tfplan` em `infrastructure/terraform/live/cloudlab`. Em PRs, comenta o resultado do plan no próprio PR via `github-script`.
- **Job `apply`** (só em push na `main`): usa `environment: production`, o que exige **aprovação manual** antes de rodar `terraform apply -auto-approve`.
- Terraform CLI: `~1.9`.

## Secrets de pipeline necessários

| Secret | Uso |
|---|---|
| `AWS_ROLE_ARN` | Role assumida via OIDC em todos os workflows |
| `AWS_ACCOUNT_ID` | Compõe o endereço do registry ECR |
| `BACKEND_IRSA_ROLE_ARN` | Anotação IRSA do ServiceAccount do backend |
| `DB_HOST` | Host do RDS injetado no backend |
| `REDIS_HOST` | Endpoint do ElastiCache injetado no backend |

## Deploy manual

Caso precise implantar fora do pipeline:

```bash
aws eks update-kubeconfig --name cloudlab-eks --region us-east-1

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

Procedimentos detalhados de deploy e rollback estão em `runbooks/deploy.md` (ver [operations.md](./operations.md)).
