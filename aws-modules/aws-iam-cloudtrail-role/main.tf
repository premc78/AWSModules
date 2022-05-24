# AWS Config Role Configuration
resource "aws_iam_role" "awscloudtrail" {
  name        = var.name
  description = "AWS CloudTrail role to allow log storage into CloudWatch"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags               = var.tags
}

# Create AWS Config role policy
resource "aws_iam_role_policy" "awsconfig" {
  name = var.name
  role = aws_iam_role.awscloudtrail.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}
