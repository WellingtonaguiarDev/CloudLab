module "acm" {
  source = "../../modules/acm"

  domain_name               = "cloudlab.example.com"
  subject_alternative_names = ["*.cloudlab.example.com"]
  hosted_zone_id            = module.route53.hosted_zone_id

  tags = local.tags
}

module "alb" {
  source = "../../modules/alb"

  network = {
    id                = module.vpc.id
    public_subnet_ids = module.vpc.network.public_subnet_ids
  }

  security_group_id = module.security-groups.alb_security_group_id
  certificate_arn   = module.acm.certificate_arn

  tags = local.tags
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  rds_identifier   = module.rds.id
  ecs_cluster_name = module.ecs.cluster_name
  alb_arn_suffix   = module.alb.arn
  kms_key_arn      = module.kms.key_arns["s3"]

  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = ["backend", "frontend"]

  tags = local.tags
}

module "efs" {
  source = "../../modules/efs"

  network = {
    id                 = module.vpc.id
    private_subnet_ids = module.vpc.network.private_subnet_ids
  }

  security_group_id = module.security-groups.efs_security_group_id
  kms_key_arn       = module.kms.key_arns["s3"]

  tags = local.tags
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

  network = {
    id                 = module.vpc.id
    private_subnet_ids = module.vpc.network.private_subnet_ids
  }

  security_group_id = module.security-groups.elasticache_security_group_id
  kms_key_arn       = module.kms.key_arns["s3"]

  tags = local.tags
}

module "security-groups" {
  source = "../../modules/security-groups"

  network = {
    id         = module.vpc.id
    cidr_block = module.vpc.cidr_block
  }

  tags = local.tags
}

module "iam" {
  source = "../../modules/iam"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  irsa_roles = {
    backend = {
      namespace       = "app"
      service_account = "backend"
      policy_arns = [
        module.iam.s3_readwrite_policy_arn,
        module.iam.secrets_readonly_policy_arn
      ]
    }
    aws-load-balancer-controller = {
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
      policy_arns     = ["arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"]
    }
    ebs-csi-driver = {
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
      policy_arns     = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
    }
    efs-csi-driver = {
      namespace       = "kube-system"
      service_account = "efs-csi-controller-sa"
      policy_arns     = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
    }
    cluster-autoscaler = {
      namespace       = "kube-system"
      service_account = "cluster-autoscaler"
      policy_arns     = ["arn:aws:iam::aws:policy/AutoScalingFullAccess"]
    }
  }

  tags = local.tags
}

module "kms" {
  source = "../../modules/kms"

  tags = local.tags
}

module "rds" {

  source = "../../modules/rds"
  network = module.vpc.network

}

module "route53" {
  source = "../../modules/route53"

  domain_name  = "cloudlab.example.com"
  alb_dns_name = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id

  tags = local.tags
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "cloudlab-storage"
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"

  kms_key_arn = module.kms.key_arns["secrets"]

  secrets = {
    "cloudlab/rds" = {
      description = "Credenciais do banco de dados RDS MySQL"
      secret_data = {
        engine   = "mysql"
        host     = module.rds.address
        port     = tostring(module.rds.port)
        dbname   = module.rds.database_name
        username = module.rds.username
      }
    }
  }

  tags = local.tags
}

module "vpc" {
  source = "../../modules/vpc"
}

module "waf" {
  source = "../../modules/waf"

  alb_arn    = module.alb.arn
  rate_limit = 2000

  tags = local.tags
}
