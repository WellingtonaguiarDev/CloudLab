# Fluxo de uma requisição

Sequência de uma chamada de API do usuário, passando pela borda até o backend e suas dependências.

```mermaid
sequenceDiagram
    autonumber
    actor U as Usuário
    participant W as WAF v2
    participant A as ALB (TLS 1.3)
    participant F as Frontend (nginx)
    participant B as Backend (Express)
    participant R as Redis
    participant D as RDS MySQL

    U->>W: HTTPS GET /
    W->>A: requisição permitida
    A->>F: rota /*
    F-->>U: SPA (HTML/JS)

    U->>W: HTTPS GET /api/items
    W->>A: requisição permitida
    A->>B: rota /api/*
    B->>R: GET items (cache)
    alt cache hit
        R-->>B: dados em cache
    else cache miss
        R-->>B: vazio
        B->>D: consulta
        D-->>B: resultado
        B->>R: SET items (EX 30s)
    end
    B-->>U: 200 JSON

    Note over B: /metrics expõe http_requests_total<br/>e http_request_duration_seconds
```

O health check (`GET /health`) e o scrape de `/metrics` seguem caminhos internos do cluster, sem passar pelo ALB público.
