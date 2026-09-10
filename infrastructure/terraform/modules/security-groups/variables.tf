variable "network" {
  description = "Network information from VPC module"
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}
