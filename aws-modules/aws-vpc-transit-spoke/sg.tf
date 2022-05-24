#############################
# Default Security Group
#############################

resource "aws_default_security_group" "baseline" {
  vpc_id = aws_vpc.spoke.id

  #Management Access
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 3389
    to_port     = 3389
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  #Foundational Services
  #SEP
  egress {
    protocol    = "tcp"
    from_port   = 8014
    to_port     = 8014
    cidr_blocks = ["10.41.29.26/32", "10.41.29.54/32", "172.28.91.212/32", "172.28.106.44/32"]
  }

  #Tanium
  egress {
    protocol    = "tcp"
    from_port   = 17472
    to_port     = 17472
    cidr_blocks = ["10.41.29.26/32"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.41.29.26/32"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 445
    to_port     = 445
    cidr_blocks = ["10.41.29.26/32"]
  }

  #DNS
  egress {
    protocol    = "tcp"
    from_port   = 53
    to_port     = 53
    cidr_blocks = ["172.31.152.86/32", "172.31.40.118/32"]
  }
  egress {
    protocol    = "udp"
    from_port   = 53
    to_port     = 53
    cidr_blocks = ["172.31.152.86/32", "172.31.40.118/32"]
  }

  #Splunk
  egress {
    protocol    = "tcp"
    from_port   = 8089
    to_port     = 8089
    cidr_blocks = ["10.40.62.86/32", "10.40.62.88/32", "10.40.62.116/32", "10.40.62.134/32", "10.40.63.87/32"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 9997
    to_port     = 9997
    cidr_blocks = ["10.40.62.86/32", "10.40.62.88/32", "10.40.62.116/32", "10.40.62.134/32", "10.40.63.87/32"]
  }

  #DCS
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["10.40.62.58/32", "10.40.62.59/32"]
  }

  #NTP
  egress {
    protocol    = "tcp"
    from_port   = 123
    to_port     = 123
    cidr_blocks = ["172.31.152.86/32", "172.31.40.118/32"]
  }
  egress {
    protocol    = "udp"
    from_port   = 123
    to_port     = 123
    cidr_blocks = ["10.40.12.13/32", "10.40.12.14/32", "172.31.47.45/32"]
  }

  #PAR
  ingress {
    protocol    = "tcp"
    from_port   = 23
    to_port     = 23
    cidr_blocks = ["10.40.12.11/32", "10.40.12.12/32", "10.42.34.21/32", "10.42.34.22/32", "10.40.6.148/32"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 445
    to_port     = 445
    cidr_blocks = ["10.40.12.11/32", "10.40.12.12/32", "10.42.34.21/32", "10.42.34.22/32", "10.40.6.148/32"]
  }

  #AD
  egress {
    protocol  = "tcp"
    from_port = 88
    to_port   = 88
    self      = true
  }
  egress {
    protocol  = "udp"
    from_port = 389
    to_port   = 389
    self      = true
  }

  #Baseline Access
  #HTTP ANY EGRESS
  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  #HTTPS ANY EGRESS
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  #LDCProxy EGRESS
  egress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["10.40.6.131/32"]
  }
  #PING ANY
  egress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    tomap({ "Name" = "${local.service_name}-spoke-default-sg" })
  )
}

