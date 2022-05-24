variable "availability_zones" {}
variable "instances" {}
variable "security_groups" {}
variable "subnets" {}
variable "bucket" {}
variable "certificate_domain" {}
variable "tags" {
  type = map(string)
}
variable "customer" {}
variable "project" {}