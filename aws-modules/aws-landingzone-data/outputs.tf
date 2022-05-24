output "vpc_id" {
  value = data.aws_vpc.lz.id
}

output "all_subnet_ids" {
  value = data.aws_subnet_ids.lz.ids
}

output "db_aza_subnet_id" {
  value = data.aws_subnet.db-aza.id
}

output "db_azb_subnet_id" {
  value = data.aws_subnet.db-azb.id
}

output "db_azc_subnet_id" {
  value = data.aws_subnet.db-azc.id
}

output "private_aza_subnet_id" {
  value = data.aws_subnet.private-aza.id
}

output "private_azb_subnet_id" {
  value = data.aws_subnet.private-azb.id
}

output "private_azc_subnet_id" {
  value = data.aws_subnet.private-azc.id
}

output "public_aza_subnet_id" {
  value = data.aws_subnet.public-aza.id
}

output "public_azb_subnet_id" {
  value = data.aws_subnet.public-azb.id
}

output "public_azc_subnet_id" {
  value = data.aws_subnet.public-azc.id
}

output "db_subnet_group_name" {
  value = var.vpc_name
}
