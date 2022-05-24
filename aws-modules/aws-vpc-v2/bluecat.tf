resource "null_resource" "bam_token" {
  provisioner "local-exec" {
    command = <<EOF
    export TF_VAR_bam_token=$(curl -X POST -H "Content-Type: application/json" --data '{ "username": "${var.bam_username}", "password": "${var.bam_password}" }' ${var.bam_url}/rest_login | jq -r '.access_token')
    echo "Test: $TF_VAR_bam_token"
EOF 
  }
}

resource "null_resource" "bam_auth" {

  depends_on = [null_resource.bam_token]
  provisioner "local-exec" {
    command = <<EOF
    echo "Test: $TF_VAR_bam_token"
EOF 
  }
}

data "http" "ip_cidr" {
  url = "${var.bam_ig_url}/VPC_Add/VPC_Add_endpoint?vnet_name=${urlencode(var.vpc_name)}&vnet_size=${urlencode(var.vpc_network_size)}&parent_block=${urlencode(var.vpc_parent_id)}"

  request_headers = {
    auth = "Basic ${var.bam_token}"
  }

  depends_on = [null_resource.bam_token]
}
