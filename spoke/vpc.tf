#############################
# VPC and Subnet(s)
#############################

locals {
  address_space = module.aws-address-space.ip_cidr
  subnets       = cidrsubnets(local.address_space, 1, 1)
  subnet_count  = var.subnet_count
  vpc_name      = "${local.service_name}-${var.vpc_suffix}"
}

resource "aws_vpc" "spoke" {
  cidr_block           = local.address_space
  enable_dns_hostnames = true
  enable_dns_support   = true

  depends_on = [
    aws_cloudwatch_log_group.spoke
  ]

  tags = merge(
    local.tags,
    tomap({ "Name" = local.vpc_name })
  )
}

resource "aws_subnet" "spoke" {
  count             = local.subnet_count
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = local.subnets[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.vpc_name}-${element(data.aws_availability_zones.available.names, count.index)}" })
  )
  depends_on = [
    aws_vpc.spoke
  ]

}

resource "aws_route_table" "spoke" {
  vpc_id = aws_vpc.spoke.id

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.vpc_name}" })
  )
  depends_on = [
    aws_vpc.spoke
  ]
}

resource "aws_route_table_association" "spoke" {
  count          = length(aws_subnet.spoke.*.id)
  subnet_id      = element(aws_subnet.spoke.*.id, count.index)
  route_table_id = aws_route_table.spoke.id
  depends_on = [
    aws_vpc.spoke,
    aws_route_table.spoke
  ]
}


#############################
# DHCP Option Set
#############################

resource "aws_vpc_dhcp_options" "zurich" {
  domain_name         = "zurich.com"
  domain_name_servers = ["172.31.152.86", "172.31.40.118"]

  tags = merge(
    local.tags,
    tomap({ "Name" = "zurich.com" })
  )
}

resource "aws_vpc_dhcp_options_association" "zurich" {
  vpc_id          = aws_vpc.spoke.id
  dhcp_options_id = aws_vpc_dhcp_options.zurich.id
}

#############################
# VPC Flow Logs
#############################

resource "aws_flow_log" "spoke" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.spoke.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke.id

  tags = merge(
    local.tags,
    tomap({ "Name" = local.vpc_name })
  )
}

resource "aws_cloudwatch_log_group" "spoke" {
  name = substr("vpc-flow-logs/${local.vpc_name}-${var.region}", 0, 63)

  tags = merge(
    local.tags,
    tomap({ "Name" = local.vpc_name })
  )
}

resource "aws_cloudwatch_log_subscription_filter" "spoke" {
  name            = aws_cloudwatch_log_group.spoke.name
  log_group_name  = aws_cloudwatch_log_group.spoke.name
  filter_pattern  = ""
  destination_arn = lookup(var.log_group_region_map, var.region)
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = substr("vpc-flow-logs-${local.vpc_name}-${var.region}", 0, 63)

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

  tags = merge(
    local.tags,
    tomap({ "Name" = local.vpc_name })
  )

}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = substr("vpc-flow-logs-${local.vpc_name}-${var.region}", 0, 63)
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

