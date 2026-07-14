resource "random_password" "this" {

  length = 32
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}