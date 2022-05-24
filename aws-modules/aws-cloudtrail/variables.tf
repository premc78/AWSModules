variable "name" {
  default     = "CloudTrail"
  description = "The cloudtrail trail name."
}

variable "region"{
  default     = ""
  description = "Region where cloudtrail exists."
}

variable "kms_key_id" {
  default     = ""
  description = "The kms key to encrypt the log data."
}

variable "enable_logging" {
  default     = true
  description = "Enable the trail."
}

variable "cloud_watch_logs_role_arn" {
  description = "The role to push logs to cloudwatch."
}

variable "cloud_watch_logs_group_arn" {
  description = "The log group for cloudtrail logs."
}

variable "auditing_bucket" {
  default     = ""
  description = "The bucket designated to publishing log files."
}

variable "snstopicname" {
  default     = ""
  description = "Leave blank to reduce notifications."
}

variable "prefix" {
  default     = ""
  description = "Leave blank to use AWS default structure."
}

variable "include_global_service_events" {
  default     = true
  description = "Includes global events."
}

variable "is_multi_region_trail" {
  default     = true
  description = "Enables CloudTrail in all regions."
}

variable "enable_log_file_validation" {
  default     = true
  description = "Creates validation files for logs."
}

variable "tags" {
  description = "Tags to apply to the trail."
}

variable "customer" {}
variable "project" {}
variable "account_id" {}
variable "acl" {
  default = "private"
}
variable "versioning" {
  default = false
}
variable "mfa_delete" {
  default = false
}
