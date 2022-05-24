output "elb_dns" {
  value = aws_alb.balancer.dns_name
}

output "elb_zone_id" {
  value = aws_alb.balancer.zone_id
}

output "elb_id" {
  value = aws_alb.balancer.id
}

output "elb_target_group_arn" {
  value = aws_alb_target_group.httptraffic.id
}

output "alb_listener_arn" {
  value = aws_alb_listener.https_other.*.arn
}

output "arn_suffix" {
  value = aws_alb.balancer.arn_suffix
}