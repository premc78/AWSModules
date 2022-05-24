# return variables
output "private_dns" {
  value = aws_instance.instance.private_dns
}

output "public_dns" {
  value = aws_instance.instance.public_dns
}

output "instance_id" {
  value = aws_instance.instance.id
}

output "eip_id" {
  value = aws_eip.ip.id
}

output "eip_public_ip" {
  value = aws_eip.ip.public_ip
}