# Catálogo de serviços

Metadados versionados de cada componente do CloudLab, no formato de entidades do [Backstage](https://backstage.io/docs/features/software-catalog/descriptor-format). Servem de base para um portal de desenvolvedor (ownership, dependências, links).

## Arquivos

| Arquivo | Componente |
|---|---|
| [backend.yaml](./backend.yaml) | API backend (Node/Express) |
| [frontend.yaml](./frontend.yaml) | SPA frontend (React/nginx) |

## Como usar

Se/quando um Backstage for instalado, registre estes arquivos como *locations*. Enquanto isso, eles documentam ownership e dependências de forma legível por máquina.

## Próximos passos

- Adicionar entidades `System` e `Resource` (RDS, Redis, S3) para mapear dependências de infraestrutura.
- Gerar as entradas automaticamente a partir dos golden paths.
