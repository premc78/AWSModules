output "name" {
  value = aws_route53_record.dns.name
}

output "fqdn" {
  value = aws_route53_record.dns.fqdn
}
