output "attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.hub.id
}

output "accepter_id" {
   value = aws_ec2_transit_gateway_vpc_attachment_accepter.hub.id
}