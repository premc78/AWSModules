data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["splunk_AMI_*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_instance" "instance" {
  count                       = var.instance_count
  ami                         = data.aws_ami.ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.vpc_security_group_ids]
  subnet_id                   = element(var.subnet_id, count.index)
  associate_public_ip_address = true
  key_name                    = var.keyname
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    encrypted   = true
    volume_size = 100
  }

  tags = merge(
    {
      Name          = "Splunk Server"
      "Environment" = "POC"
    },
    var.tags,
  )
}