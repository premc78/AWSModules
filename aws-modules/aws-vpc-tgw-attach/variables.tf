variable "spoke_vpc_id" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "role_to_assume_arn" {
  type = string
}

variable "tgw_name" {
  type = string
}

variable "transit_gateway_route_table_id" {
  type = string
}

variable "region" {
  type = string
}

variable "spoke_subnet_ids" {
  type = list(string)
}

variable "spoke_route_table_ids" {
  type = list(string)
}

variable "edge_connectivity" {
  default = true
}

variable "segmentation_connectivity" {
  default = true
}

variable "tags" {
  type = map(any)
}

variable "service_name" {
  type    = string
  default = "TGW-Attachment"
}

locals {
  service_name = var.service_name
  tags         = var.tags
}
