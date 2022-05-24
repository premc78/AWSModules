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
variable "role_to_assume_arn" {}

#############################
# Workload specific variables
#############################

variable "vpc_primary_cidr" {}
variable "vpc_suffix" {}
variable "subnet_count" {
  type    = string
  default = 2
}

variable "splunk_logs_destination" {
  type = map(any)
  default = {
    eu-west-1    = "arn:aws:logs:eu-west-1:213267611577:destination:zig-aws-ct-splunk-logs-destination-eu-west-1"
    eu-central-1 = "arn:aws:logs:eu-central-1:213267611577:destination:zig-aws-ct-splunk-logs-destination-eu-central-1"
  }
}

#############################
# Local definitions
#############################

locals {
  service_name = lower("${var.customer}-${var.project}-${var.environment}")
  tags         = var.tags
}
