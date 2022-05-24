variable "subnetid" {}

variable "keypair" {
  default = ""
}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_type" {}

variable "security_groups" {
  type = list(string)
}

variable "userdata" {
  default = ""
}

variable "iam_instance_profile" {
  default = ""
}

variable "associate_public_ip_address" {
  default = false
}

variable "ami_search" {
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-"

}

variable "use_eip" {
  default = false
}