variable "env" {}
variable "vpcid" {}
variable "sslcert" {}
variable "albtargetprotocol" {}
variable "albtargetport" {}

variable "internal" {
  default     = "false"
  description = "Access this ALB internally only."
}

variable "enable_deletion_protection" {
  default     = "false"
  description = "Enable deletion protection."
}

variable "access_logs_bucket" {
  default     = "vccmelblogs"
  description = "Bucket to store the access logs."
}

variable "http2_enabled" {
  default = "true"
}

variable "access_logs_prefix" {
  default     = ""
  description = "Standard is project-env."
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "instanceid" {
  default = ""
}

variable "elb_sg" {}

variable "subnets" {
  type = list(string)
}

variable "albtargetpath" {
  default = "/"
}

variable "elb_sslports" {
  default = []
}

variable "elb_httpports" {
  default = []
}

variable "idle_timeout" {
  default = "60"
}

variable "ssl_policy" {
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}
