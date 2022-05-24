#############################
# Common Variables
#############################

variable "customer" {}
variable "project" {}
variable "environment" {}
variable "tags" {
  type = map(string)
}
variable "region" {}
variable "role_to_assume_arn" {}

variable "log_group_region_map" {
  default = {
    eu-west-1    = "arn:aws:logs:eu-west-1:213267611577:destination:zig-aws-ct-splunk-logs-destination-eu-west-1"
    eu-central-1 = "arn:aws:logs:eu-central-1:213267611577:destination:zig-aws-ct-splunk-logs-destination-eu-central-1"
  }
}

#############################
# Workload specific variables
#############################

variable "subnet_count" {
  type    = string
  default = 2
}

variable "vpc_suffix" {
  default = "spoke"
}

#############################
# BAM variables
#############################

variable "bam_username" {}
variable "bam_password" {}
variable "bam_base_url" {}
variable "vpc_size" { default = 32 }
variable "tgw_name" {
  type    = string
  default = "ZEMEA Transit Gateway"
}

variable "bam_token" { default = "changeme" }

variable "bam_region_map" {
  type = map(string)
  default = {
    "eu-west-1"    = "awswest"
    "eu-central-1" = "awscent"
  }
}

variable "bam_environment_map" {
  type = map(string)
  default = {
    "Prod"    = "prod"
    "UAT"     = "uat"
    "SIT"     = "dev"
    "Dev"     = "dev"
    "Sandbox" = "dev"
  }
}

#############################
# Local definitions
#############################

locals {
  service_name    = lower("${var.customer}-${var.project}-${var.environment}")
  bam_object_name = "${local.service_name}-${var.vpc_suffix}"
  tags            = var.tags
}
