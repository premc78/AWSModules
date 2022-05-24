variable "alarm_namespace" {
  default     = "CISBenchmark"
  description = "The namespace in which all alarms are set up."
}

variable "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Logs group to which CloudTrail events are delivered."
}

variable "sns_topic_arn" {
  description = "The SNS topic ARN to send the alerts to."
}

variable "tags" {}
variable "environment" {}