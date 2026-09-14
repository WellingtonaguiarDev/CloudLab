# Fluxo de CI/CD

Três workflows GitHub Actions com autenticação OIDC (sem chaves estáticas).

```mermaid
flowchart LR
    dev([Push / PR na main])

    dev -->|applications/**| ci
    dev -->|infrastructure/terraform/**| tf

    subgraph ci["CI · ci.yaml"]
        ci_build[Build backend + frontend]
        ci_push[Push ECR<br/>tags sha8 + latest]
        ci_build --> ci_push
    end

    subgraph cd["CD · cd.yaml"]
        cd_kube[update-kubeconfig]
        cd_helm[helm upgrade --atomic<br/>backend + frontend]
        cd_verify[kubectl rollout status]
        cd_kube --> cd_helm --> cd_verify
    end

    subgraph tf["Terraform · terraform.yaml"]
        tf_plan[init · validate · plan]
        tf_comment[Comenta plan no PR]
        tf_apply[apply -auto-approve<br/>environment: production]
        tf_plan --> tf_comment
        tf_plan --> tf_apply
    end

    ci_push -->|workflow_run success| cd_kube
    cd_helm --> ecr[(ECR)]
    cd_helm --> eks[(EKS · namespace app)]
    tf_apply --> awsenv[(Infra AWS)]
```

- **CI**: dispara em mudanças de `applications/**`; build/push só ocorre na `main`.
- **CD**: dispara ao concluir o CI com sucesso; `--atomic` faz rollback automático em falha.
- **Terraform**: `plan` sempre (comenta no PR); `apply` só em push na `main` e requer aprovação manual do environment `production`.

Detalhes em [../docs/deployment.md](../docs/deployment.md).
