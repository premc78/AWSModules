variable "create_route" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = false
}

variable "name" {}
variable "vpc_id" {}
variable "destination_cidr" {}
variable "gateway_id" {}
variable "egress_only_gateway_id" {}
variable "instance_id" {}
variable "nat_gateway_id" {}
variable "network_interface_id" {}
variable "transit_gateway_id" {}
variable "vpc_peering_connection_id" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}