variable "sns_topic_name" {
  description = "SNS Topic name."
}

variable "sns_display_name" {
  description = "SNS topic display name. (Max 10 chars)"
}

variable "tags" {}

variable "subscription_endpoint" {
  default = null
}

variable "protocol" {
  type    = string
  default = "sqs"
}
