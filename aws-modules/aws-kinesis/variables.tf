variable "name" {
  description = "A name to identify the stream"
  type        = string
}
variable "shard_count" {
  description = "The number of shards that the stream will use."
  type        = string
  default     = "1"
}

variable "retention_period" {
  description = "Length of time data records are accessible after they are added to the stream"
  type        = string
  default     = "24"
}

variable "shard_level_metrics" {
  description = "A list of shard-level CloudWatch metrics which can be enabled for the stream"
  type        = list
  default = [
  ]
}

variable "enforce_consumer_deletion" {
  description = "A boolean that indicates all registered consumers should be deregistered from the stream"
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "The encryption type to use"
  type        = string
  default     = "NONE"
}

variable "kms_key_id" {
  description = "The GUID for the customer-managed KMS key to use for encryption"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the kinesis resource"
  type        = map
  default = {
  }
}

