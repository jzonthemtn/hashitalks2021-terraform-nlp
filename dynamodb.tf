resource "aws_dynamodb_table" "models_dynamodb_table" {
  name           = "${var.name_prefix}-models"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ModelID"

  attribute {
    name = "ModelID"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

}
