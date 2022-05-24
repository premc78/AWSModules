variable "description" {}

variable "ports" {
  type        = list(string)
  description = "A list of ports to allow"
}

variable "security_group_id" {}

variable "source_security_group_id" {
  type    = string
  default = null
}

variable "cidr_blocks" {
  type    = list(string)
  default = null
}

variable "protocol" {
  default = "tcp"
}

variable "type" {
  default = "ingress"
}