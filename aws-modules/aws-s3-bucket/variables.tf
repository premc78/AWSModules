variable "region" {
  description = "The region for the bucket."
  type        = string
}

variable "business" {
  description = "The business unit name."
  type        = string
}

variable "bucket" {
  description = "The name of the bucket."
  type        = string
}

variable "custom_bucket_policy" {
  description = "JSON formatted bucket policy to add to the bucket."
  type        = string
  default     = ""
}

variable "logging_bucket" {
  description = "The S3 bucket to send S3 access logs to if different."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = map(string)
}
