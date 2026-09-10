# Runbook: Operações de Infraestrutura

## Aplicar mudanças no Terraform

```bash
cd infrastructure/terraform/live/cloudlab

# Inicializar
terraform init

# Planejar
terraform plan -out=tfplan

# Revisar e aplicar
terraform apply tfplan
```

## Destruir infraestrutura (cuidado!)

```bash
# Apenas em ambiente de desenvolvimento/testes
terraform destroy
```

## Adicionar novo módulo

1. Criar diretório em `infrastructure/terraform/modules/<nome>/`
2. Criar `variables.tf`, `main.tf`, `outputs.tf`
3. Adicionar bloco `module` em `infrastructure/terraform/live/cloudlab/modules.tf`
4. Rodar `terraform init` para registrar o módulo
5. Rodar `terraform plan` para validar

## Atualizar kubeconfig

```bash
aws eks update-kubeconfig \
  --name cloudlab-eks \
  --region us-east-1
```

## Instalar/atualizar controllers do kube-system

```bash
# EBS CSI Driver
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  -n kube-system -f kubernetes/kube-system/aws-ebs-csi-driver/values.yaml

# EFS CSI Driver
helm upgrade --install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
  -n kube-system -f kubernetes/kube-system/aws-efs-csi-driver/values.yaml

# AWS Load Balancer Controller
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system -f kubernetes/kube-system/aws-load-balancer-controller/values.yaml

# Cluster Autoscaler
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  -n kube-system -f kubernetes/kube-system/cluster-autoscaler/values.yaml

# Metrics Server
helm upgrade --install metrics-server metrics-server/metrics-server \
  -n kube-system -f kubernetes/kube-system/metrics-server/values.yaml
```

## Instalar stack de monitoring

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/prometheus/values.yaml

# Aplicar ServiceMonitors e alertas
kubectl apply -f monitoring/prometheus/servicemonitor.yaml
kubectl apply -f monitoring/prometheus/alerts.yaml
kubectl apply -f monitoring/grafana/dashboards/cloudlab.yaml
```

## Acessar Grafana localmente

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
# Abrir http://localhost:3000 — admin / changeme
```

## Recuperar senha do RDS no Secrets Manager

```bash
aws secretsmanager get-secret-value \
  --secret-id cloudlab/rds \
  --query SecretString \
  --output text \
  --region us-east-1 | jq .
```
