resource "aws_dynamodb_table" "vault-dynamodb-table" {
  name           = var.table_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Path"
  range_key      = "Key"
  attribute {
    name = "Path"
    type = "S"
  }
  attribute {
    name = "Key"
    type = "S"
  }
  tags = var.tags
}