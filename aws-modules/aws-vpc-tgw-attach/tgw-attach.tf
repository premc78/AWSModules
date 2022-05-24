#############################
# TGW Attachment
#############################

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  subnet_ids         = var.spoke_subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.spoke_vpc_id

  depends_on = [aws_ram_resource_share.hub, aws_ram_resource_association.hub, aws_ram_principal_association.hub]

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.service_name}-spoke-tgw-attachment" })
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "hub" {
  provider = aws.networking

  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.service_name}-spoke-tgw-attachment" })
  )
}

#############################
# TGW RTB Edge
#############################

resource "aws_ec2_transit_gateway_route_table_association" "transit" {
  provider = aws.networking

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.hub]
}

#############################
# TGW RAM
#############################

resource "aws_ram_resource_share" "hub" {
  provider = aws.networking

  name = "${data.aws_caller_identity.networking.account_id}-${data.aws_caller_identity.current.account_id}-zemea-tgw"

  tags = merge(
    local.tags,
    tomap({ "Name" = "${data.aws_caller_identity.networking.account_id}-${data.aws_caller_identity.current.account_id}-zemea-tgw" })
  )
}

resource "aws_ram_resource_association" "hub" {
  provider = aws.networking

  resource_arn       = data.aws_ec2_transit_gateway.hub.arn
  resource_share_arn = aws_ram_resource_share.hub.id
}

resource "aws_ram_principal_association" "hub" {
  provider = aws.networking

  principal          = data.aws_caller_identity.current.account_id
  resource_share_arn = aws_ram_resource_share.hub.id
}
