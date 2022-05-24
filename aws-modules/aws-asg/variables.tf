variable "security_group_ids" {}
variable "tags" {}
variable "instance_type" {}
variable "ami_id" {}
variable "description" {}
variable "launch_template_prefix" {}
variable "asg_tags" {}
variable "subnet_id" {}
variable "asg_name_prefix" {}
variable "vpc_subnet_ids" {}

variable "associate_public_ip_address" {
  default = true
}

variable "user_data" {
  default = ""
}

variable "key_pair_name" {
  default = ""
}

variable "iam_instance_profile_name" {
  default = ""
}

variable "ebs_optimized" {
  default = ""
}

variable "volume_size" {
  default = "100"
}

variable "volume_encrypted" {
  default = true
}

variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}