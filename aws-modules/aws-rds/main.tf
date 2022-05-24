resource "aws_db_instance" "main_rds_instance" {
  identifier                          = lower(var.rds_instance_identifier)
  allocated_storage                   = var.rds_allocated_storage
  engine                              = var.rds_engine_type
  engine_version                      = length(var.rds_engine_version) > 0 ? var.rds_engine_version : var.rds_engine_version[var.rds_engine_type]
  instance_class                      = var.rds_instance_class
  name                                = var.database_name
  username                            = var.database_user
  password                            = var.database_password
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  port                                = var.database_port[var.rds_engine_type]
  license_model                       = var.license_model
  iam_database_authentication_enabled = var.iam_enabled
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  # Because we're assuming a VPC, we use this option, but only one SG id
  vpc_security_group_ids = [aws_security_group.main_db_access.id]
  db_subnet_group_name   = var.db_subnet_group_name
  availability_zone      = var.availability_zone

  # We want the multi-az setting to be toggleable, but off by default
  multi_az            = var.rds_is_multi_az
  storage_type        = var.rds_storage_type
  publicly_accessible = var.publicly_accessible

  # Upgrades
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  # Snapshots and backups
  skip_final_snapshot   = var.skip_final_snapshot
  copy_tags_to_snapshot = var.copy_tags_to_snapshot

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  tags = var.tags

  # Dont replace already built (from a snapshot) RDS instance
  lifecycle {
    ignore_changes = [
      snapshot_identifier,
      engine_version,
      availability_zone,
    ]
  }

  parameter_group_name  = var.parameter_group_name
  option_group_name     = var.option_group_name
  performance_insights_enabled = false
}

# Security groups
resource "aws_security_group" "main_db_access" {
  name        = "${var.rds_instance_identifier}db-access"
  description = "Allow access to the database"
  vpc_id      = var.rds_vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "allow_db_access" {
  type = "ingress"

  from_port                = var.database_port[var.rds_engine_type]
  to_port                  = var.database_port[var.rds_engine_type]
  protocol                 = "tcp"
  source_security_group_id = var.web_sg

  security_group_id = aws_security_group.main_db_access.id
}

resource "aws_security_group_rule" "allow_db_vpn" {
  type                     = "ingress"
  from_port                = var.database_port[var.rds_engine_type]
  to_port                  = var.database_port[var.rds_engine_type]
  protocol                 = "tcp"
  source_security_group_id = var.vpn_sg

  security_group_id = aws_security_group.main_db_access.id

  count = var.env == "dev" ? 1 : 0
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main_db_access.id
}

