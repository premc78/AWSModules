#############################
# Subnet Routes
#############################

resource "aws_route" "default_route" {
  count                  = var.edge_connectivity == true ? length(var.spoke_route_table_ids) : 0
  route_table_id         = element(var.spoke_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.hub.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub, aws_ec2_transit_gateway_vpc_attachment_accepter.hub]
}

resource "aws_route" "route_10" {
  count                  = var.segmentation_connectivity == true ? length(var.spoke_route_table_ids) : 0
  route_table_id         = element(var.spoke_route_table_ids, count.index)
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = data.aws_ec2_transit_gateway.hub.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub, aws_ec2_transit_gateway_vpc_attachment_accepter.hub]
}

resource "aws_route" "route_172" {
  count                  = var.segmentation_connectivity == true ? length(var.spoke_route_table_ids) : 0
  route_table_id         = element(var.spoke_route_table_ids, count.index)
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = data.aws_ec2_transit_gateway.hub.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub, aws_ec2_transit_gateway_vpc_attachment_accepter.hub]
}

resource "aws_route" "route_192" {
  count                  = var.segmentation_connectivity == true ? length(var.spoke_route_table_ids) : 0
  route_table_id         = element(var.spoke_route_table_ids, count.index)
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = data.aws_ec2_transit_gateway.hub.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub, aws_ec2_transit_gateway_vpc_attachment_accepter.hub]
}

#############################
# Transit Gateway Routes
#############################

resource "aws_ec2_transit_gateway_route" "return" {
  provider = aws.networking

  destination_cidr_block         = data.aws_vpc.spoke.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_return.id

  depends_on = [data.aws_ec2_transit_gateway.hub, aws_ec2_transit_gateway_vpc_attachment.hub, aws_ec2_transit_gateway_vpc_attachment_accepter.hub]

}
