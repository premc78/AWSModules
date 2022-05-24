
locals {
  names            = split("-", lower(var.vpc_name))
  bam_vpc_region  = lookup(var.bam_region_map, var.region)
  bam_environment  = lookup(var.bam_environment_map, local.names[2], "dev")
  bam_auth_payload = jsonencode({username = var.bam_username, password = var.bam_password})
  bam_api_params   = jsonencode({region = local.bam_vpc_region, environment = local.bam_environment, name = var.vpc_name, size = var.vpc_size})
}

data "external" "bam_api" {
  program = ["bash", "${path.module}/bam_api.sh"]

  query = {
    "bam_base_url"     = var.bam_base_url
    "bam_auth_payload" = local.bam_auth_payload
    "bam_region"       = local.bam_vpc_region
    "bam_environment"  = local.bam_environment
    "vpc_name"        = urlencode(var.vpc_name)
    "vpc_size"        = var.vpc_size
  }
}


