# Visão DevOps (resumo)

Diagrama vertical das áreas de DevOps cobertas pelo CloudLab. Formato retrato, pensado para leitura em feed (LinkedIn/celular). Imagem exportada em [exports/devops-overview.png](./exports/devops-overview.png).

```mermaid
flowchart TB
    hub(["☁️ CloudLab · DevOps end-to-end na AWS"])
    iac["🏗️ IaC — Terraform · 17 módulos"]
    app["💻 Aplicações — Node/Express · React"]
    cont["📦 Containers & Orquestração — Docker · Kubernetes (EKS)"]
    cicd["🚀 CI/CD — GitHub Actions · OIDC"]
    deploy["⚙️ Deploy — Helm atômico · rollback"]
    obs["📊 Observabilidade — Prometheus · Grafana · alertas"]
    sec["🔒 Segurança — WAF · KMS · Secrets · RBAC · PSS"]
    net["🌐 Networking — VPC multi-AZ · ALB · Route53"]
    scale["⚖️ Escalabilidade & HA — HPA · Cluster Autoscaler · 3 AZs"]

    hub --> iac --> app --> cont --> cicd --> deploy --> obs --> sec --> net --> scale

    linkStyle default stroke-width:0px;

    classDef hub fill:#6366F1,stroke:#4338CA,stroke-width:2px,color:#ffffff;
    classDef box fill:#EEF2FF,stroke:#6366F1,stroke-width:1px,color:#1e293b;
    class hub hub;
    class iac,app,cont,cicd,deploy,obs,sec,net,scale box;
```
