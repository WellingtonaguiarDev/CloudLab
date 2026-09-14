# Tools

Scripts utilitários para tarefas recorrentes do CloudLab. Todos são bash, sem dependências além das ferramentas da stack (`terraform`, `helm`, `kubectl`, `aws`).

| Script | Descrição |
|---|---|
| [`validate.sh`](./validate.sh) | Valida Terraform (fmt/validate) e Helm (lint/template) localmente |
| [`kubeconfig.sh`](./kubeconfig.sh) | Atualiza o kubeconfig para o cluster EKS `cloudlab-eks` |
| [`deploy.sh`](./deploy.sh) | Deploy manual dos charts backend/frontend via Helm |
| [`new-service.sh`](./new-service.sh) | Scaffolding de um novo serviço a partir do golden path Node |

## Uso

```bash
# Dê permissão de execução (uma vez)
chmod +x tools/*.sh

tools/validate.sh
tools/kubeconfig.sh
tools/deploy.sh <image-tag>
tools/new-service.sh orders 8080
```

Variáveis de ambiente relevantes (com defaults): `AWS_REGION=us-east-1`, `EKS_CLUSTER=cloudlab-eks`, `NAMESPACE=app`, `ECR_REGISTRY`.
