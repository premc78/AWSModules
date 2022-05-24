locals {
  resource_types_string = "[\"${join("\", \"", var.resource_types)}\"]"
}

resource "aws_resourcegroups_group" "group" {
    name = var.name

  resource_query {
    query = templatefile("${path.module}/ResourceTypeFilters.tpl", { resource_types = local.resource_types_string, tag_name = var.tag_name, tag_value=var.tag_value })
  }

  tags = var.tags
}