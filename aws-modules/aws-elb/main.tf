data "aws_acm_certificate" "splunk_ssl_cert" {
  domain   = var.certificate_domain
  statuses = ["ISSUED"]
}

data "aws_elb_service_account" "main" {}

# Create S3 bucket for ELB logs
# Allow ELB service account write/put access
resource "aws_s3_bucket" "splunk_elb_logs" {
  bucket        = format("%s-%s-splunk-elb-logs", var.customer, var.project)
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${format("%s-%s-splunk-elb-logs", var.customer, var.project)}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY

  tags = var.tags
}

# Create Classic Load-Balancer to sit in front of Splunk EC2 instance
# Terminate SSL connections at load-balancer
resource "aws_elb" "splunk_elb" {
  name            = "splunk-lb-tf"
  security_groups = [var.security_groups]
  subnets         = flatten([var.subnets])

  access_logs {
    bucket   = aws_s3_bucket.splunk_elb_logs.bucket
    interval = 5
  }

  listener {
    instance_port      = 8088
    instance_protocol  = "http"
    lb_port            = 8088
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.splunk_ssl_cert.arn
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:8088/services/collector/health/1.0"
    interval            = 30
  }

  instances                   = var.instances
  cross_zone_load_balancing   = true
  idle_timeout                = 600
  connection_draining         = true
  connection_draining_timeout = 300

  tags = var.tags
}

# Custmize ELB cookie stickiness policy
resource "aws_lb_cookie_stickiness_policy" "splunk_elb_stickiness_policy" {
  name          = "splunk-elb-stickiness-policy"
  load_balancer = aws_elb.splunk_elb.id
  lb_port       = 8088
}

