resource "aws_dynamodb_table" "models_dynamodb_table" {
  name         = "${var.name_prefix}-models"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "modelId"

  attribute {
    name = "modelId"
    type = "S"
  }

}
