variable "tags" {}
variable "name" {}

variable "scan_on_push" {
  default = true
}

variable "image_tag_mutability" {
  default = "MUTABLE"
}

