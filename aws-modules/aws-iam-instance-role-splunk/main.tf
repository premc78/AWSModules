resource "aws_iam_role" "splunk_access_role" {
    name    = format("splunk-access-role-%s", var.project)

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

    tags = var.tags
}

resource "aws_iam_role_policy" "splunk_access_role_policy" {
    name    = format("splunk-access-role-policy-%s", var.project)
    role    = aws_iam_role.splunk_access_role.id

    policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:*"
        ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
    name    = format("splunk-access-instance-profile-%s", var.project)
    role    = aws_iam_role.splunk_access_role.name
}