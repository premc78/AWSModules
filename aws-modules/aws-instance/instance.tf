data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = var.ami_search
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["amazon", "099720109477"]
}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ami.image_id
  instance_type               = var.instance_type
  key_name                    = var.keypair
  vpc_security_group_ids      = var.security_groups
  tags                        = var.tags
  user_data                   = var.userdata
  subnet_id                   = var.subnetid
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile
  root_block_device {
    encrypted   = true
    volume_size = 100
  }
  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

resource "aws_eip" "ip" {
  vpc  = true
  tags = var.tags
}

resource "aws_eip_association" "ipassoc" {
  instance_id   = aws_instance.instance.id
  allocation_id = aws_eip.ip.id
}