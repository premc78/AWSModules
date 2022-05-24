
module "aws-address-space" {
  source             = "../../aws-modules/aws-address-space"
  bam_username       = var.bam_username
  bam_password       = var.bam_password
  bam_base_url       = var.bam_base_url
  region             = var.region
  vpc_name           = local.bam_object_name
  vpc_size           = var.vpc_size
  role_to_assume_arn = var.role_to_assume_arn
}

module "aws-vpc-tgw-attach" {
  source                         = "../../aws-modules/aws-vpc-tgw-attach"
  providers = {
    aws.networking = aws.networking
  }
  spoke_vpc_id                   = aws_vpc.spoke.id
  transit_gateway_id             = data.aws_ec2_transit_gateway.hub.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit.id
  region                         = var.region
  spoke_subnet_ids               = aws_subnet.spoke.*.id
  service_name                   = local.vpc_name
  tags                           = local.tags
  role_to_assume_arn             = var.role_to_assume_arn
  tgw_name                       = var.tgw_name
  spoke_route_table_ids          = [aws_route_table.spoke.id]
  depends_on                     = [aws_vpc.spoke, aws_route_table.spoke]
}