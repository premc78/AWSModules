#############################
# Transit Gateway Share
#############################

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_caller_identity" "networking" {
  provider = aws.networking
}

data "aws_ec2_transit_gateway" "hub" {
  provider = aws.networking
  filter {
    name   = "tag:Name"
    values = ["ZEMEA Transit Gateway"]
  }

  filter {
    name   = "tag:Region"
    values = [var.region]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_ram_resource_share" "hub" {
  provider = aws.networking

  name = "${data.aws_caller_identity.networking.account_id}-${data.aws_caller_identity.current.account_id}-zemea-tgw"

  tags = merge(
    local.tags,
    tomap({"Name"= "${data.aws_caller_identity.networking.account_id}-${data.aws_caller_identity.current.account_id}-zemea-tgw"})
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

#############################
# TGW RTB Share 
#############################

data "aws_ec2_transit_gateway_route_table" "transit" {
  provider = aws.networking
  filter {
    name   = "tag:Type"
    values = ["Transit"]
  }

  filter {
    name   = "tag:Region"
    values = [var.region]
  }

  filter {
    name   = "transit-gateway-id"
    values = [data.aws_ec2_transit_gateway.hub.id]
  }
}

data "aws_ec2_transit_gateway_route_table" "transit_return" {
  provider = aws.networking
  filter {
    name   = "tag:Type"
    values = ["Transit Return"]
  }

  filter {
    name   = "tag:Region"
    values = [var.region]
  }

  filter {
    name   = "transit-gateway-id"
    values = [data.aws_ec2_transit_gateway.hub.id]
  }
}
