resource "aws_launch_template" "launch_template" {
  name_prefix   = var.launch_template_prefix
  description   = var.description
  image_id      = var.ami_id
  instance_type = var.instance_type
  ebs_optimized = var.ebs_optimized
  key_name      = var.key_pair_name
  user_data     = base64encode(var.user_data)
  tags          = var.tags
  credit_specification {
    cpu_credits = "standard"
  }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  monitoring {
    enabled = true
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = "true"
      encrypted             = var.volume_encrypted
    }
  }
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_group_ids
    delete_on_termination       = true
    subnet_id                   = var.subnet_id
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix         = var.asg_name_prefix
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  health_check_type   = "EC2"
  vpc_zone_identifier = var.vpc_subnet_ids
  tags                = var.asg_tags

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}