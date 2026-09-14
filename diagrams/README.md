# Diagramas

Diagramas da arquitetura do CloudLab em [Mermaid](https://mermaid.js.org/), renderizáveis direto no GitHub e no VS Code (com a extensão Markdown Preview Mermaid Support).

| Diagrama | Conteúdo |
|---|---|
| [architecture.md](./architecture.md) | Arquitetura geral AWS (borda → EKS → dados) |
| [network.md](./network.md) | Topologia de rede da VPC (AZs, subnets, NAT) |
| [cicd.md](./cicd.md) | Fluxo dos pipelines CI / CD / Terraform |
| [request-flow.md](./request-flow.md) | Sequência de uma requisição do usuário à resposta |
| [terraform-modules.md](./terraform-modules.md) | Dependências entre os módulos Terraform |
| [devops-overview.md](./devops-overview.md) | Resumo vertical das áreas DevOps (para feed/LinkedIn) |

## Imagens exportadas

Versões em imagem ficam em [`exports/`](./exports/):

| Imagem | Fonte |
|---|---|
| [exports/architecture.png](./exports/architecture.png) | [architecture.md](./architecture.md) |
| [exports/devops-overview.png](./exports/devops-overview.png) | [devops-overview.md](./devops-overview.md) |

> Para exportar como imagem (PNG/SVG), use a [Mermaid Live Editor](https://mermaid.live) ou o `mmdc` (mermaid-cli):
>
> ```bash
> npx @mermaid-js/mermaid-cli -i diagram.mmd -o diagram.png -b white -w 1600
> ```
