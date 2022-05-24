# CloudWatch logs group creation
resource "aws_cloudwatch_log_group" "default" {
  retention_in_days = 90
  name              = var.name
  tags              = var.tags
}
