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
module "eks" {
  source = "../../modules/eks"
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
}

module "route53" {
  source = "../../modules/route53"
}

module "s3" {
  source = "../../modules/s3"
}

module "security-groups" {
  source = "../../modules/security-groups"
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
