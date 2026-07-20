variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "network" {
  type = any
}

variable "instance_types" {
  type = list(string)

  default = [
    "t3.medium"
  ]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "tags" {
  type    = map(string)
  default = {}
}