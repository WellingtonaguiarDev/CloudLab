# Dependências entre módulos Terraform

Como os módulos em `infrastructure/terraform/live/cloudlab/modules.tf` se encadeiam (outputs de um alimentando inputs de outro).

```mermaid
flowchart TD
    vpc[vpc]
    eks[eks]
    ecs[ecs]
    iam[iam]
    rds[rds]
    redis[elasticache]
    efs[efs]
    sg[security-groups]
    kms[kms]
    secrets[secrets-manager]
    alb[alb]
    acm[acm]
    r53[route53]
    waf[waf]
    cw[cloudwatch]
    s3[s3]
    ecr[ecr]

    vpc --> eks
    vpc --> ecs
    vpc --> rds
    vpc --> efs
    vpc --> redis
    vpc --> sg
    vpc --> alb

    eks -->|oidc| iam

    sg --> alb
    sg --> redis
    sg --> efs

    kms --> secrets
    kms --> efs
    kms --> redis
    kms --> cw

    acm --> alb
    r53 --> acm
    alb --> r53
    alb --> waf
    alb --> cw

    rds --> secrets
    rds --> cw
    ecs --> cw
```

Módulos sem dependências de outros (recebem só `tags`/inputs próprios): `s3`, `ecr`, `kms`, `vpc`.

Detalhes de cada módulo em [../docs/infrastructure.md](../docs/infrastructure.md).
