resource "aws_alb" "balancer" {
  name                       = "${var.name}-${var.env}-alb"
  internal                   = var.internal
  security_groups            = [var.elb_sg]
  subnets                    = var.subnets
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.http2_enabled
  access_logs {
    bucket = var.access_logs_bucket
    prefix = var.access_logs_prefix
  }

  tags = var.tags
}

# Create a target group for HTTP traffic
resource "aws_alb_target_group" "httptraffic" {
  name     = "${var.name}-${var.env}-${var.albtargetport}"
  port     = var.albtargetport
  protocol = "HTTP"
  vpc_id   = var.vpcid

  stickiness {
    type    = "lb_cookie"
    enabled = "false"
  }

  health_check {
    path                = var.albtargetpath
    port                = var.albtargetport
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200-302"
  }
  tags = var.tags
}

# Create a redirect listener for HTTP traffic
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.balancer.arn
  port              = var.elb_httpports[count.index]
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  count = length(var.elb_httpports)
}

# Create a listener for SSL traffic
resource "aws_alb_listener" "https_other" {
  load_balancer_arn = aws_alb.balancer.arn
  port              = var.elb_sslports[count.index]
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.sslcert

  default_action {
    target_group_arn = aws_alb_target_group.httptraffic.arn
    type             = "forward"
  }

  count = length(var.elb_sslports)
}

# Attach the instance to the HTTP group
resource "aws_alb_target_group_attachment" "http" {
  target_group_arn = aws_alb_target_group.httptraffic.arn
  target_id        = var.instanceid
  port             = var.albtargetport
  count            = length(var.instanceid) > 0 ? 1 : 0
}

