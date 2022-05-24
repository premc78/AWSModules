resource "aws_flow_log" "example" {
    count = var.create_vpc ? 1 : 0
    iam_role_arn    = aws_iam_role.example[count.index].arn
    log_destination = aws_cloudwatch_log_group.example[count.index].arn
    traffic_type    = "ALL"
    vpc_id          = aws_vpc.this[count.index].id
}

resource "aws_cloudwatch_log_group" "example" {
    count = var.create_vpc ? 1 : 0
    name = lower(format("flowlog-%s", aws_vpc.this[count.index].id))
    retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "example" {
    count = var.create_vpc ? 1 : 0
    name = lower(format("vpc-flowlog-role-%s", aws_vpc.this[count.index].id))

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

resource "aws_cloudwatch_log_subscription_filter" "vpc_flowlogs" {
  count = var.create_vpc ? 1 : 0
  name            = "Destination"
  log_group_name  = lower(format("flowlog-%s", aws_vpc.this[count.index].id))
  filter_pattern  = "" 
  destination_arn = var.cw_log_dest_arn
  depends_on      = [aws_cloudwatch_log_group.example]
}

resource "aws_iam_role_policy" "example" {
    count = var.create_vpc ? 1 : 0
    name = lower(format("vpc-flowlog-role-policy-%s", aws_vpc.this[count.index].id))
    role = aws_iam_role.example[count.index].id

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