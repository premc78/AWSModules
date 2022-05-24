variable "bam_username" {}
variable "bam_password" {}
variable "bam_base_url" {}
variable "vpc_name" {}
variable "vpc_size" {}
variable "region" {}
variable "role_to_assume_arn" {}

variable "bam_region_map" {
  default = {
      "eu-west-1" = "awswest"
      "eu-central-1" = "awscent"
  }
}

variable "bam_environment_map" {
  default = {
    "prod" = "prod"
    "uat"  = "uat"
    "sit"  = "dev"
    "dev"  = "dev"
    "sbx"  = "dev"
  }
}