#############################
# Common Variables
#############################

variable "project" {}
variable "customer" {}
variable "environment" {}
variable "tags" {
  type = map(string)
}
variable "region" {}

#############################
# Workload specific variables
#############################

variable "vpc_primary_cidr" {}
variable "vpc_secondary_cidr" {}
variable "subnet_diff" {
  type    = string
  default = 1
}

variable "onprem_conn" { default = false }
variable "internet_conn" { default = false }
variable "bgp_asn" { default = "64978" } #Amazons default ASN

#############################
# Region mapped variables VPC
#############################

# TO-DO - Need to map vars for frankfurt

variable "palo_edge_az1_ip" {
  type = map
  default = {
    eu-west-1 = "34.252.141.179"
  }
}

variable "palo_edge_az2_ip" {
  type = map
  default = {
    eu-west-1 = "63.32.124.248"
  }
}

variable "palo_edge_bgp_asn" {
  type = map
  default = {
    eu-west-1 = "64986"
  }
}

variable "palo_transit_az1_ip" {
  type = map
  default = {
    eu-west-1 = "34.253.126.123"
  }
}

variable "palo_transit_az2_ip" {
  type = map
  default = {
    eu-west-1 = "34.240.241.122"
  }
}

variable "palo_transit_bgp_asn" {
  type = map
  default = {
    eu-west-1 = "64980"
  }
}

#############################
# Local definitions
#############################

locals {
  service_name = lower("${var.customer}-${var.project}-${var.environment}")
  tags         = var.tags
}
