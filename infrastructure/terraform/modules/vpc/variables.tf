variable "network" {
  description = "Configuração da rede VPC"
  type = object({
    cidr_block = string
    name       = string
    region     = string
  })

  default = {
    cidr_block = "172.22.0.0/16"
    name       = "PROD-cloudlab-VPC"
    region     = "us-east-1"
  }
}

variable "subnets" {
  description = "Lista de subnets da VPC"
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))

  default = [
    # =========================
    # Public subnets (/20)
    # =========================
    {
      name                    = "PROD-Subnet-Public-A"
      cidr_block              = "172.22.0.0/20"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    },
    {
      name                    = "PROD-Subnet-Public-B"
      cidr_block              = "172.22.16.0/20"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = true
    },
    {
      name                    = "PROD-Subnet-Public-C"
      cidr_block              = "172.22.32.0/20"
      availability_zone       = "us-east-1c"
      map_public_ip_on_launch = true
    },

    # =========================
    # Private subnets (/19)
    # =========================
    {
      name                    = "PROD-Subnet-Private-A"
      cidr_block              = "172.22.64.0/19"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = false
    },
    {
      name                    = "PROD-Subnet-Private-B"
      cidr_block              = "172.22.96.0/19"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = false
    },
    {
      name                    = "PROD-Subnet-Private-C"
      cidr_block              = "172.22.128.0/19"
      availability_zone       = "us-east-1c"
      map_public_ip_on_launch = false
    }
  ]
}