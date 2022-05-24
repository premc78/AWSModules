resource "aws_route53_zone" "primary" {
  name    = var.domain_name
  comment = var.comment
  tags    = var.tags
}