variable "bucket_name" {

  description = "S3 bucket name."
  type = string
  default = "cloudlab-storage"
}


variable "encryption_algorithm" {

  description = "S3 server side encryption algorithm."
  type = string
  default = "AES256"
}


variable "block_public_acls" {

  description = "Block public ACLs."
  type = bool
  default = true
}


variable "block_public_policy" {

  description = "Block public bucket policies."
  type = bool
  default = true
}


variable "ignore_public_acls" {

  description = "Ignore public ACLs."
  type = bool
  default = true
}


variable "restrict_public_buckets" {

  description = "Restrict public buckets."
  type = bool
  default = true
}


variable "tags" {

  description = "Tags."
  type = map(string)
  default = {}

}