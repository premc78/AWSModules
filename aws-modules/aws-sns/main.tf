resource "aws_sns_topic" "thetopic" {
  name         = var.sns_topic_name
  display_name = var.sns_display_name
  tags         = var.tags
}

resource "aws_sqs_queue" "queue" {
  count = var.subscription_endpoint == null ? 1 : 0
  name = format("%s-queue", var.sns_display_name)
  tags         = var.tags
}

resource "aws_sns_topic_subscription" "sqs_target" {
  count = var.subscription_endpoint == null ? 0 : 0
  topic_arn = aws_sns_topic.thetopic.arn
  protocol  = var.protocol
  endpoint  = aws_sqs_queue.queue[count.index].arn
}

resource "aws_sns_topic_subscription" "custom_target" {
  count = var.subscription_endpoint != null ? 1 : 0
  topic_arn = aws_sns_topic.thetopic.arn
  protocol  = var.protocol
  endpoint  = var.subscription_endpoint
}