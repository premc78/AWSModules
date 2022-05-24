provider "aws" {
  region = var.region
  assume_role {
    role_arn     = var.role_to_assume_arn
    session_name = "TerraformExecution"
  }
}

provider "aws" {
  alias  = "networking"
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::131558913184:role/TransitGatewayRole"
    session_name = "TerraformExecution"
  }
}
