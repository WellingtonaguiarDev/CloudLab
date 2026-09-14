# Tests

Testes de validação do CloudLab. Focam em detectar regressões de configuração (Terraform, Helm) e no comportamento básico das aplicações, sem exigir uma conta AWS.

| Teste | O que cobre | Requer |
|---|---|---|
| [`terraform.sh`](./terraform.sh) | `terraform fmt -check` + `validate` no ambiente `live/cloudlab` | terraform |
| [`helm.sh`](./helm.sh) | `helm lint` + `helm template` dos charts backend/frontend | helm |
| [`backend-smoke.sh`](./backend-smoke.sh) | Sobe o backend e checa `/health`, `/api/items` e `/metrics` | node, curl |
| [`run-all.sh`](./run-all.sh) | Executa todos os testes acima e agrega o resultado | — |

## Uso

```bash
chmod +x tests/*.sh
tests/run-all.sh
```

Cada script sai com código `0` em sucesso e `1` em falha, então servem tanto localmente quanto em CI.

## Observações

- `terraform validate` requer `terraform init` (baixa providers). O script tenta um init sem backend; em ambiente offline ele apenas roda o `fmt -check`.
- `backend-smoke.sh` roda sem MySQL/Redis: o `/health` responde `200` com as dependências marcadas como `down`, o que é esperado localmente.
- Para testes de contrato mais completos, considere adicionar [terratest](https://terratest.gruntwork.io/) (Go) ou [conftest](https://www.conftest.dev/) (políticas OPA sobre os manifests renderizados).
