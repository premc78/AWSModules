#############################
# VPC and Subnet(s)
#############################

locals {
  cidr_subnets = {
    1 = [var.vpc_primary_cidr]
    2 = cidrsubnets(var.vpc_primary_cidr, 1, 1)
    3 = cidrsubnets(var.vpc_primary_cidr, 2, 2, 2)
  }
}

resource "aws_vpc" "spoke" {
  cidr_block           = var.vpc_primary_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  depends_on = [
    aws_cloudwatch_log_group.spoke
  ]

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.service_name}-${var.vpc_suffix}" })
  )
}

resource "aws_subnet" "spoke" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = var.subnet_count == 1 ? var.vpc_primary_cidr : element(lookup(local.cidr_subnets, var.subnet_count), count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.service_name}-${var.vpc_suffix}-${element(data.aws_availability_zones.available.names, count.index)}" })
  )
}


resource "aws_route_table" "spoke" {
  count  = var.subnet_count
  vpc_id = aws_vpc.spoke.id

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.service_name}-${var.vpc_suffix}" })
  )
}

resource "aws_route_table_association" "spoke" {
  count          = length(aws_subnet.spoke.*.id)
  subnet_id      = element(aws_subnet.spoke.*.id, count.index)
  route_table_id = element(aws_route_table.spoke.*.id, count.index)
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
}

resource "aws_cloudwatch_log_group" "spoke" {
  name = "vpc-flow-logs/${local.service_name}-${var.vpc_suffix}"
}

resource "aws_cloudwatch_log_subscription_filter" "splunk" {
  name            = "Destination"
  log_group_name  = aws_cloudwatch_log_group.spoke.name
  filter_pattern  = ""
  destination_arn = lookup(var.splunk_logs_destination, var.region)
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs-${local.service_name}-${var.vpc_suffix}"

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
  name = "vpc-flow-logs-${local.service_name}-${var.vpc_suffix}"
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

