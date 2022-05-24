resource "aws_kinesis_stream" "stream" {
  name                      = var.name
  shard_count               = var.shard_count
  shard_level_metrics       = var.shard_level_metrics
  retention_period          = var.retention_period
  enforce_consumer_deletion = var.enforce_consumer_deletion
  encryption_type           = var.encryption_type
  tags                      = var.tags
}
