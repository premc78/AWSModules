variable "vpc_security_group_ids" {}
variable "availability_zones" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "instance_count" {}
variable "keyname" {}
variable "tags" {
  type = map(string)
}
