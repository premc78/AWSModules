data "aws_vpc" "lz" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "lz" {
  vpc_id = data.aws_vpc.lz.id
}

data "aws_subnet" "db-aza" {
  tags = {
    Name = format("%s-db-%sa", var.vpc_name, var.region)
  }
}

data "aws_subnet" "db-azb" {
  tags = {
    Name = format("%s-db-%sb", var.vpc_name, var.region)
  }
}

data "aws_subnet" "db-azc" {
  tags = {
    Name = format("%s-db-%sc", var.vpc_name, var.region)
  }
}

data "aws_subnet" "private-aza" {
  tags = {
    Name = format("%s-private-%sa", var.vpc_name, var.region)
  }
}

data "aws_subnet" "private-azb" {
  tags = {
    Name = format("%s-private-%sb", var.vpc_name, var.region)
  }
}

data "aws_subnet" "private-azc" {
  tags = {
    Name = format("%s-private-%sc", var.vpc_name, var.region)
  }
}

data "aws_subnet" "public-aza" {
  tags = {
    Name = format("%s-public-%sa", var.vpc_name, var.region)
  }
}

data "aws_subnet" "public-azb" {
  tags = {
    Name = format("%s-public-%sb", var.vpc_name, var.region)
  }
}

data "aws_subnet" "public-azc" {
  tags = {
    Name = format("%s-public-%sc", var.vpc_name, var.region)
  }
}