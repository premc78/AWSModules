output "splunk_elb_dns_name" {
  value = aws_elb.splunk_elb.dns_name
}

output "splunk_elb_main_zone_id" {
  value = aws_elb.splunk_elb.zone_id
}