module "acm" {
  source = "../../modules/acm"
}

module "alb" {
  source = "../../modules/alb"
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"
}

module "ecr" {
  source = "../../modules/ecr"
}

module "efs" {
  source = "../../modules/efs"
}

module "ecs" {

  source = "../../modules/ecs"
  cluster_name = "cloudlab-ecs"
  service_name = "nginx"
  container_image = "nginx:latest"

  network = module.vpc.network

  tags = {
    Project = "CloudLab"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "cloudlab-eks"
  cluster_version = "1.33"

  network = module.vpc.network

  instance_types = [
    "t3.medium"
  ]

  desired_size = 2
  min_size     = 2
  max_size     = 4

  tags = {
    Environment = "prod"
  }
}

module "elasticache" {
  source = "../../modules/elasticache"
}

module "iam" {
  source = "../../modules/iam"
}

module "kms" {
  source = "../../modules/kms"
}

module "rds" {

  source = "../../modules/rds"
  network = module.vpc.network

}

module "route53" {
  source = "../../modules/route53"
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "cloudlab-storage"
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "waf" {
  source = "../../modules/waf"
}
