output "vpc_id" {
  value = aws_vpc.spoke.id
}

output "subnet_ids" {
  value = aws_subnet.spoke.*.id
}

output "baseline_sg_id" {
  value = aws_default_security_group.baseline.id
}

output "aws_route_table_id" {
  value = aws_route_table.spoke.id
}