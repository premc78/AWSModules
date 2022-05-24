#PUBLIC SUBNET FLOWLOGS
resource "aws_flow_log" "public_subnet_flowlog" {
    count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
    iam_role_arn    = aws_iam_role.public_subnet_flowlog[count.index].arn
    log_destination = aws_cloudwatch_log_group.public_subnet_flowlog[count.index].arn
    traffic_type    = "ALL"
    subnet_id         = aws_subnet.public[count.index].id
}

resource "aws_cloudwatch_log_group" "public_subnet_flowlog" {
    count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
    name = lower(format("flowlog-%s", aws_subnet.public[count.index].id))
    retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_subscription_filter" "public_subnet_flowlog" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  name            = "Destination"
  log_group_name  = lower(format("flowlog-%s", aws_subnet.public[count.index].id))
  filter_pattern  = "" 
  destination_arn = var.cw_log_dest_arn
  depends_on      = [aws_cloudwatch_log_group.public_subnet_flowlog]
}

resource "aws_iam_role" "public_subnet_flowlog" {
    count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
    name = lower(format("subnet-flowlog-role-%s", aws_subnet.public[count.index].id))

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

resource "aws_iam_role_policy" "public_subnet_flowlog" {
    count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
    name = lower(format("vpc-flowlog-role-policy-%s", aws_subnet.public[count.index].id))
    role = aws_iam_role.public_subnet_flowlog[count.index].id

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

#PRIVATE SUBNET FLOWLOGS
resource "aws_flow_log" "private_subnet_flowlog" {
    count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
    iam_role_arn    = aws_iam_role.private_subnet_flowlog[count.index].arn
    log_destination = aws_cloudwatch_log_group.private_subnet_flowlog[count.index].arn
    traffic_type    = "ALL"
    subnet_id         = aws_subnet.private[count.index].id
}

resource "aws_cloudwatch_log_group" "private_subnet_flowlog" {
    count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
    name = lower(format("flowlog-%s", aws_subnet.private[count.index].id))
    retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_subscription_filter" "private_subnet_flowlog" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  name            = "Destination"
  log_group_name  = lower(format("flowlog-%s", aws_subnet.private[count.index].id))
  filter_pattern  = "" 
  destination_arn = var.cw_log_dest_arn
  depends_on      = [aws_cloudwatch_log_group.private_subnet_flowlog]
}

resource "aws_iam_role" "private_subnet_flowlog" {
    count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
    name = lower(format("subnet-flowlog-role-%s", aws_subnet.private[count.index].id))

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

resource "aws_iam_role_policy" "private_subnet_flowlog" {
    count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
    name = lower(format("vpc-flowlog-role-policy-%s", aws_subnet.private[count.index].id))
    role = aws_iam_role.private_subnet_flowlog[count.index].id

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

#DATABASE SUBNET FLOWLOGS
resource "aws_flow_log" "database_subnet_flowlog" {
    count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
    iam_role_arn    = aws_iam_role.database_subnet_flowlog[count.index].arn
    log_destination = aws_cloudwatch_log_group.database_subnet_flowlog[count.index].arn
    traffic_type    = "ALL"
    subnet_id         = aws_subnet.database[count.index].id
}

resource "aws_cloudwatch_log_group" "database_subnet_flowlog" {
    count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
    name = lower(format("flowlog-%s", aws_subnet.database[count.index].id))
    retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_subscription_filter" "database_subnet_flowlog" {
  count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
  name            = "Destination"
  #log_group_name  = lower(format("flowlog-%s", aws_subnet.database[count.index].id))
  log_group_name = aws_cloudwatch_log_group.database_subnet_flowlog[count.index].name
  filter_pattern  = "" 
  destination_arn = var.cw_log_dest_arn
  depends_on      = [aws_cloudwatch_log_group.database_subnet_flowlog]
}

resource "aws_iam_role" "database_subnet_flowlog" {
    count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
    name = lower(format("subnet-flowlog-role-%s", aws_subnet.database[count.index].id))

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

resource "aws_iam_role_policy" "database_subnet_flowlog" {
    count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0
    name = lower(format("vpc-flowlog-role-policy-%s", aws_subnet.database[count.index].id))
    role = aws_iam_role.database_subnet_flowlog[count.index].id

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

#INTRA SUBNET FLOWLOGS
resource "aws_flow_log" "intra_subnet_flowlog" {
    count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0
    iam_role_arn    = aws_iam_role.intra_subnet_flowlog[count.index].arn
    log_destination = aws_cloudwatch_log_group.intra_subnet_flowlog[count.index].arn
    traffic_type    = "ALL"
    subnet_id         = aws_subnet.intra[count.index].id
}

resource "aws_cloudwatch_log_group" "intra_subnet_flowlog" {
    count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0
    name = lower(format("flowlog-%s", aws_subnet.intra[count.index].id))
    retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_subscription_filter" "intra_subnet_flowlog" {
  count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0
  name            = "Destination"
  log_group_name  = lower(format("flowlog-%s", aws_subnet.intra[count.index].id))
  filter_pattern  = "" 
  destination_arn = var.cw_log_dest_arn
  depends_on      = [aws_cloudwatch_log_group.intra_subnet_flowlog]
}

resource "aws_iam_role" "intra_subnet_flowlog" {
    count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0
    name = lower(format("subnet-flowlog-role-%s", aws_subnet.intra[count.index].id))

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

resource "aws_iam_role_policy" "intra_subnet_flowlog" {
    count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0
    name = lower(format("vpc-flowlog-role-policy-%s", aws_subnet.intra[count.index].id))
    role = aws_iam_role.intra_subnet_flowlog[count.index].id

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