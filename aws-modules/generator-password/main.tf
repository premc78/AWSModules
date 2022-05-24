resource "random_string" "password" {
  length           = var.length
  upper            = true
  lower            = true
  number           = true
  special          = true
  override_special = "_"
}

