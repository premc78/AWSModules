#
# Module: tf_aws_rds
#

# RDS Instance Variables
variable "env" {
  default     = "prod"
  description = "The environment (qa, dev, prod, uat)"
}

variable "rds_instance_identifier" {
  description = "Custom name of the instance"
}

variable "web_sg" {
  description = "Security group to allow access to the db"
  default     = ""
}

variable "vpn_sg" {
  description = "Security group to allow access to the db"
  default     = ""
}

variable "rds_is_multi_az" {
  description = "Set to true on production"
  default     = false
  type        = bool
}

variable "rds_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "gp2"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in GBs"
  default     = "100"
  # You just give it the number, e.g. 10
}

variable "rds_engine_type" {
  description = "Database engine type"
  default     = "mysql"
  # Valid types are
  # - mysql
  # - postgres
  # - oracle-*
  # - sqlserver-*
  # See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
  # --engine
}

variable "rds_engine_version" {
  description = "Database engine version, depends on engine type"

  default = {
    aurora        = "Version 5.6"
    mariadb       = "10.2"
    mysql         = "5.7.23"
    oracle-ee     = "11.2"
    oracle-se2    = "11.2"
    oracle-se1    = "11.2"
    oracle-se     = "11.2"
    postgres      = "9.4"
    sqlserver-ee  = "13.00"
    sqlserver-se  = "13.00"
    sqlserver-ex  = "13.00"
    sqlserver-web = "13.00"
  }
  # For valid engine versions, see:
  # See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
  # --engine-version
}

variable "rds_instance_class" {
  description = "Class of RDS instance"
  default     = "db.t2.small"
  # Valid values
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  # As we are defaulting encryption to true, the smallest we can use is db.t2.small 
}

variable "auto_minor_version_upgrade" {
  description = "Allow automated minor version upgrade"
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade"
  default     = false
}

variable "database_name" {
  description = "The name of the database to create"
  default     = ""
}

variable "license_model" {
  description = "License model information for this DB instance."
  default     = ""
}

# Self-explainatory variables
variable "database_user" {
  default = ""
}

variable "database_password" {
  default = ""
}

variable "db_subnet_group_name" {
}

variable "database_port" {
  description = "Database port, depends on engine type"

  default = {
    aurora        = "3306"
    mariadb       = "3306"
    mysql         = "3306"
    oracle-ee     = "1521"
    oracle-se2    = "1521"
    oracle-se1    = "1521"
    oracle-se     = "1521"
    postgres      = "5432"
    sqlserver-ee  = "1433"
    sqlserver-se  = "1433"
    sqlserver-ex  = "1433"
    sqlserver-web = "1433"
  }
}

variable "publicly_accessible" {
  description = "Determines if database can be publicly available (NOT recommended)"
  default     = false
}

# RDS Subnet Group Variables
variable "rds_vpc_id" {
  description = "VPC to connect to, used for a security group"
  type        = string
}

variable "skip_final_snapshot" {
  description = "If true (default), no snapshot will be made before deleting DB"
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags from DB to a snapshot"
  default     = true
}

variable "backup_window" {
  description = "When AWS can run snapshot, can't overlap with maintenance window"
  default     = "05:00-05:30"
}

variable "maintenance_window" {
  description = "When AWS can perform maintenance"
  default     = "Sun:06:00-Sun:06:30"
}

variable "backup_retention_period" {
  type        = string
  description = "How long will we retain backups"
  default     = 35
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}

variable "snapshot_identifier" {
  description = "Snapshot ID if restoring from a snapshot"
  default     = ""
}

variable "storage_encrypted" {
  description = "Will the RDS instance be encrypted or not"
  default     = "true"
}

variable "availability_zone" {
  description = "availability zone for the DB"
  default     = ""
}

variable "iam_enabled" {
  default = false
}

variable "option_group_name" {
  description = "The option group name"
  default     = ""
}

variable "parameter_group_name" {
  description = "The parameter group name"
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs"
  default     = ""
  # Valid types are
  # - mysql and MariaDB
  # -- audit, error, general, slowquery
  # - postgres
  # -- postgresql, upgrade
  # - oracle-*
  # -- alert, audit, listener, trace
  # - sqlserver-*
  # -- agent , error
}