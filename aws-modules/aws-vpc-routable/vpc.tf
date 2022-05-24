#############################
# VPC and Subnet(s)
#############################

locals {
  public_subnets  = cidrsubnets(var.vpc_primary_cidr, 1, 1)
  private_subnets = cidrsubnets(var.vpc_secondary_cidr, 1, 1)
}

resource "aws_vpc" "routable_vpc" {
  cidr_block           = var.vpc_primary_cidr
  enable_dns_hostnames = false
  enable_dns_support   = true


  tags = merge(
    local.tags,
    map("Name", "${local.service_name}-routable-vpc")
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.routable_vpc.id
  cidr_block = var.vpc_secondary_cidr
}

resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.available.names) - var.subnet_diff
  vpc_id            = aws_vpc.routable_vpc.id
  cidr_block        = local.public_subnets[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Public Subnet - ${element(data.aws_availability_zones.available.names, count.index)}"
    Tier = "Public"
  }
}

resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.available.names) - var.subnet_diff
  vpc_id            = aws_vpc.routable_vpc.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Private Subnet - ${element(data.aws_availability_zones.available.names, count.index)}"
    Tier = "Private"
  }
}

resource "aws_route_table" "public" {
  vpc_id           = aws_vpc.routable_vpc.id
  propagating_vgws = local.vgw_ids

  tags = merge(
    local.tags,
    map("Name", "${local.service_name}-routable-subnet")
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.routable_vpc.id

  tags = merge(
    local.tags,
    map("Name", "${local.service_name}-routable-subnet")
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

#############################
# Internet Connectivity
#############################

resource "aws_customer_gateway" "palo_edge_az1" {
  count      = var.internet_conn == true ? 1 : 0         #Only create if internet_conn is true
  bgp_asn    = lookup(var.palo_edge_bgp_asn, var.region) #Lookup BGP ASN based on variable map
  ip_address = lookup(var.palo_edge_az1_ip, var.region)  #Lookup IP based on variable map
  type       = "ipsec.1"                                 #Hardcoded as only supported value

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-edge-az1")
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_customer_gateway" "palo_edge_az2" {
  count      = var.internet_conn == true ? 1 : 0         #Only create if internet_conn is true
  bgp_asn    = lookup(var.palo_edge_bgp_asn, var.region) #Lookup BGP ASN based on variable map
  ip_address = lookup(var.palo_edge_az2_ip, var.region)  #Lookup IP based on variable map
  type       = "ipsec.1"                                 #Hardcoded as only supported value

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-edge-az2")
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpn_connection" "palo_edge_az1" {
  count               = var.internet_conn == true ? 1 : 0 #Only create if internet_conn is true
  vpn_gateway_id      = aws_vpn_gateway.vgw_amazon[count.index].id
  customer_gateway_id = aws_customer_gateway.palo_edge_az1[count.index].id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-edge-az1")
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpn_connection" "palo_edge_az2" {
  count               = var.internet_conn == true ? 1 : 0 #Only create if internet_conn is true
  vpn_gateway_id      = aws_vpn_gateway.vgw_amazon[count.index].id
  customer_gateway_id = aws_customer_gateway.palo_edge_az2[count.index].id
  type                = "ipsec.1"
  static_routes_only  = false



  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-edge-az2")
  )

  lifecycle {
    prevent_destroy = true
  }
}

#############################
# On Prem Connectivity
#############################

resource "aws_customer_gateway" "palo_transit_az1" {
  count      = var.onprem_conn == true ? 1 : 0              #Only create if onprem_conn is true
  bgp_asn    = lookup(var.palo_transit_bgp_asn, var.region) #Lookup BGP ASN based on variable map
  ip_address = lookup(var.palo_transit_az1_ip, var.region)  #Lookup IP based on variable map
  type       = "ipsec.1"                                    #Hardcoded as only supported value

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-transit-az1")
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_customer_gateway" "palo_transit_az2" {
  count      = var.onprem_conn == true ? 1 : 0              #Only create if onprem_conn is true
  bgp_asn    = lookup(var.palo_transit_bgp_asn, var.region) #Lookup BGP ASN based on variable map
  ip_address = lookup(var.palo_transit_az2_ip, var.region)  #Lookup IP based on variable map
  type       = "ipsec.1"                                    #Hardcoded as only supported value

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-transit-az2")
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Add any static routes here 

resource "aws_vpn_connection" "palo_transit_az1" {
  count               = var.onprem_conn == true ? 1 : 0 #Only create if onprem_conn is true
  vpn_gateway_id      = aws_vpn_gateway.vgw_amazon[count.index].id
  customer_gateway_id = aws_customer_gateway.palo_transit_az1[count.index].id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-transit-az1")
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpn_connection" "palo_transit_az2" {
  count               = var.onprem_conn == true ? 1 : 0 #Only create if onprem_conn is true
  vpn_gateway_id      = aws_vpn_gateway.vgw_amazon[count.index].id
  customer_gateway_id = aws_customer_gateway.palo_transit_az2[count.index].id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = merge(
    local.tags,
    map("Name", "${var.region}-palo-transit-az2")
  )

  lifecycle {
    prevent_destroy = true
  }
}

#############################
# Amazon Side VPN Gateway
#############################

resource "aws_vpn_gateway" "vgw_amazon" {
  count           = var.internet_conn == true || var.onprem_conn == true ? 1 : 0 #Only create if internet_conn or onprem_conn is true
  vpc_id          = aws_vpc.routable_vpc.id
  amazon_side_asn = var.bgp_asn

  tags = merge(
    local.tags,
    map("Name", "${local.service_name}-vpn-gw")
  )

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  vgw_ids = [aws_vpn_gateway.vgw_amazon.id]
}

#############################
# DHCP Option Set
#############################

resource "aws_vpc_dhcp_options" "zurich" {
  domain_name         = "zurich.com"
  domain_name_servers = ["172.31.152.86", "172.31.40.118"]

  tags = merge(
    local.tags,
    map("Name", "zurich")
  )
}

resource "aws_vpc_dhcp_options_association" "zurich" {
  vpc_id          = aws_vpc.routable_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.zurich.id
}

#############################
# VPC Flow Logs
#############################

resource "aws_flow_log" "routable_vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.routable_vpc.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.routable_vpc_v2.id
}

resource "aws_cloudwatch_log_group" "routable_vpc" {
  name = "vpc-flow-logs/${local.service_name}-routable-vpc"
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs"
  role = aws_iam_role.vpc_flow_logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
