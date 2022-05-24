variable "tags" {
  type = map(string)
}

variable "customer" {}
variable "project" {}
variable "name" {}

variable "acl" {
  default = "private"
}
variable "versioning" {
  default = false
}
variable "mfa_delete" {
  default = false
}
