# Diagramas

Diagramas da arquitetura do CloudLab em [Mermaid](https://mermaid.js.org/), renderizáveis direto no GitHub e no VS Code (com a extensão Markdown Preview Mermaid Support).

| Diagrama | Conteúdo |
|---|---|
| [architecture.md](./architecture.md) | Arquitetura geral AWS (borda → EKS → dados) |
| [network.md](./network.md) | Topologia de rede da VPC (AZs, subnets, NAT) |
| [cicd.md](./cicd.md) | Fluxo dos pipelines CI / CD / Terraform |
| [request-flow.md](./request-flow.md) | Sequência de uma requisição do usuário à resposta |
| [terraform-modules.md](./terraform-modules.md) | Dependências entre os módulos Terraform |

> Para exportar como imagem (PNG/SVG), use a [Mermaid Live Editor](https://mermaid.live) ou o `mmdc` (mermaid-cli).
