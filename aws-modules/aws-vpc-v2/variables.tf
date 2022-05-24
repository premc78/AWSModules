variable "vpc_name" {
  type = string
  default = "ccoe-bluecat-VPC"
}

variable "vpc_network_size" {
  type = string
  default = 64
}

variable "vpc_parent_id" {
  type = string
  default = "166642364"
}

variable "bam_token" {
  type = string
}

variable "bam_ig_url" {
    type = string
    default = "http://10.132.108.130"
}

variable "bam_username" {
  type = string
  default = "ccoe-azure-test"
}

variable "bam_password" {
  type = string
  default = "AFqDiALYba9"
}