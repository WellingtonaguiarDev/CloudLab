# Platform

Camada de **Platform Engineering** do CloudLab: as abstrações e automações que permitem aos times de aplicação entregar em produção por um caminho pavimentado (paved road), sem precisar dominar toda a infraestrutura por baixo.

## Conteúdo

| Pasta | Propósito |
|---|---|
| [golden-paths/](./golden-paths/) | Templates de projeto (paved roads) para novos serviços |
| [gitops/](./gitops/) | Configuração declarativa de GitOps com Argo CD (App of Apps) |
| [catalog/](./catalog/) | Catálogo de serviços / metadados (estilo Backstage) |

## Ideia central

- **Golden paths**: um dev que precisa de um novo microserviço parte de um template já alinhado com os contratos da plataforma (porta, `/health`, `/metrics`, Helm chart, pipeline). Ver [golden-paths/](./golden-paths/).
- **GitOps**: o estado do cluster é declarado em Git; o Argo CD reconcilia continuamente. Ver [gitops/](./gitops/).
- **Catálogo**: cada serviço se descreve em metadados versionados, base para um portal de desenvolvedor. Ver [catalog/](./catalog/).

> Esta camada é um **esqueleto documentado** — define a estrutura e as convenções da plataforma. Os componentes (Argo CD, portal) devem ser instalados/conectados conforme a evolução do projeto; cada subpasta indica os próximos passos.
