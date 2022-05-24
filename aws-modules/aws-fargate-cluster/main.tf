resource "aws_ecs_cluster" "cluster" {
  name               = var.cluster_name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}