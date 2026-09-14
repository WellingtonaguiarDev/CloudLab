# Topologia de rede

VPC `PROD-cloudlab-VPC` (`172.22.0.0/16`) com 3 zonas de disponibilidade. Subnets públicas hospedam o ALB e o NAT Gateway; recursos de compute e dados ficam nas privadas.

```mermaid
flowchart TB
    igw[Internet Gateway]

    subgraph vpc["VPC 172.22.0.0/16"]
        subgraph azA["us-east-1a"]
            pubA["Public A<br/>172.22.0.0/20"]
            privA["Private A<br/>172.22.64.0/19"]
        end
        subgraph azB["us-east-1b"]
            pubB["Public B<br/>172.22.16.0/20"]
            privB["Private B<br/>172.22.96.0/19"]
        end
        subgraph azC["us-east-1c"]
            pubC["Public C<br/>172.22.32.0/20"]
            privC["Private C<br/>172.22.128.0/19"]
        end

        nat[NAT Gateway<br/>EIP dedicado]
        alb[ALB]
        nodes[Nós EKS · ECS · RDS · Redis · EFS]
    end

    internet([Internet]) --> igw --> pubA & pubB & pubC
    pubA --> nat
    alb --- pubA & pubB & pubC
    nodes --- privA & privB & privC
    privA & privB & privC -->|saída| nat --> igw
```

- 1 NAT Gateway (na subnet pública A) provê saída de internet para as subnets privadas.
- NACLs separadas para camadas pública e privada.
- RDS, Redis e EFS não têm acesso público.
