resource "aws_kms_key" "kafkakmskey" {
  description         = "Kafka KMS Key"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_security_group" "kafkasg" {
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_security_group_rule" "cluster_sg_rule" {
  from_port                = 9092
  protocol                 = "tcp"
  source_security_group_id = var.eks_cluster_sg_id
  security_group_id        = aws_security_group.kafkasg.id
  to_port                  = 9094
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_sg_rule" {
  from_port                = 9092
  protocol                 = "tcp"
  source_security_group_id = var.eks_worker_sg_id
  security_group_id        = aws_security_group.kafkasg.id
  to_port                  = 9094
  type                     = "ingress"
}

resource "aws_msk_cluster" "zipkinmsk" {
  cluster_name           = format("%s-%s-%s-zipkin-msk", var.customer, var.project, var.environment)
  kafka_version          = "2.2.1"
  number_of_broker_nodes = 2

  enhanced_monitoring = "PER_TOPIC_PER_BROKER"

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = "1000"
    client_subnets  = var.client_subnets
    security_groups = [aws_security_group.kafkasg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kafkakmskey.arn
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
    }
  }
  tags = var.tags
}
