data "aws_caller_identity" "current" {}

data "aws_caller_identity" "networking" {
  provider = aws.networking
}

data "aws_vpc" "spoke" {
  id = var.spoke_vpc_id
}

data "aws_ec2_transit_gateway" "hub" {
  provider = aws.networking
  filter {
    name   = "tag:Name"
    values = [var.tgw_name]
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


output "subnet_ids" {
  value = var.spoke_subnet_ids[0]
}