resource "aws_vpc" "main" {
  cidr_block       = data.http.ip_cidr.body
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc_name}"
  }
}

