# GitOps (Argo CD)

Modelo declarativo de entrega contínua para o cluster EKS usando **Argo CD** no padrão **App of Apps**: um `Application` raiz aponta para um diretório que contém os demais `Application`s (apps e add-ons). O Argo CD reconcilia continuamente o estado do cluster com o Git.

## Estrutura

```
gitops/
├── bootstrap/
│   └── root-app.yaml        # Application raiz (App of Apps)
└── applications/
    ├── backend.yaml         # Application do backend (Helm chart do repo)
    └── frontend.yaml        # Application do frontend
```

## Como funciona

```
Git (este repo) ──► Argo CD ──► reconcilia ──► EKS (namespace app)
       ▲                                              │
       └──────────── estado desejado ◄───────────────┘
```

1. Instale o Argo CD no cluster (namespace `argocd`).
2. Aplique o `bootstrap/root-app.yaml` uma única vez.
3. O root-app descobre os `Application`s em `applications/` e os sincroniza.
4. A partir daí, mudanças no Git são refletidas no cluster automaticamente.

## Relação com o pipeline atual

Hoje o deploy é **push-based** via `cd.yaml` (helm upgrade a partir do GitHub Actions). O GitOps é uma alternativa **pull-based**: o CI continua fazendo build/push da imagem no ECR, mas o deploy passa a ser o Argo CD sincronizando o Git. As duas abordagens não devem coexistir para o mesmo recurso — escolha uma como fonte de verdade do deploy.

## Próximos passos

- Instalar Argo CD (`helm install argocd argo/argo-cd -n argocd`).
- Ajustar `repoURL` nos manifests para a URL real do repositório.
- Definir a estratégia de atualização de imagem (ex: Argo CD Image Updater) para fechar o loop com o CI.
