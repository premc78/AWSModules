resource "aws_iam_instance_profile" "instanceprofile" {
  name = var.name
  role = aws_iam_role.instanceprofile.name
}

resource "aws_iam_role" "instanceprofile" {
  name        = var.name
  path        = "/"
  description = "Instance role for ${var.name}"

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
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "instanceprofile-admin" {
  role       = aws_iam_role.instanceprofile.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}