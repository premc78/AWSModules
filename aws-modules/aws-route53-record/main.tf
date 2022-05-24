resource "aws_route53_record" "dns" {
  zone_id         = var.zone_id
  name            = var.dns_name
  type            = var.type
  ttl             = var.ttl
  records         = var.records
  health_check_id = var.health_check_id
}
