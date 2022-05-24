##########################
# Route table association
##########################
resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

resource "aws_route" "egress_only_gateway_id" {
  count = length(var.egress_only_gateway_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  egress_only_gateway_id = var.egress_only_gateway_id

  depends_on = [var.egress_only_gateway_id]
}

resource "aws_route" "gateway_id" {
  count = length(var.gateway_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  gateway_id = var.gateway_id

  depends_on = [var.gateway_id]
}

resource "aws_route" "instance_id" {
  count = length(var.instance_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  instance_id = var.instance_id

  depends_on = [var.instance_id]
}

resource "aws_route" "nat_gateway_id" {
  count = length(var.nat_gateway_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  nat_gateway_id = var.nat_gateway_id

  depends_on = [var.nat_gateway_id]
}

resource "aws_route" "network_interface_id" {
  count = length(var.network_interface_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  network_interface_id = var.network_interface_id

  depends_on = [var.network_interface_id]
}

resource "aws_route" "transit_gateway_id" {
  count = length(var.transit_gateway_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  transit_gateway_id = var.transit_gateway_id

  depends_on = [var.transit_gateway_id]
}

resource "aws_route" "vpc_peering_connection_id" {
  count = length(var.vpc_peering_connection_id) > 0 ? 1 : 0
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.destination_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id

  depends_on = [var.vpc_peering_connection_id]
}