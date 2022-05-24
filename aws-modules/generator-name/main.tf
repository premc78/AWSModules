resource "random_string" "name" {
  length  = var.length
  upper   = true
  lower   = true
  number  = false
  special = false
}

