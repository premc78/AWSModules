variable "health_check_id" {
  default = ""
}

variable "records" {
  type = list(string)
}

variable "ttl" {
  default = "300"
}

variable "type" {
  default = "CNAME"
}

variable "dns_name" {}
variable "zone_id" {}
