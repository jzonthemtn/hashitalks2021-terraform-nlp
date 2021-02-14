resource "aws_dynamodb_table" "models_dynamodb_table" {
  name         = "${var.name_prefix}-models"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "modelId"
  range_key    = "status"

  attribute {
    name = "modelId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name               = "StatusIndex"
    hash_key           = "status"
    write_capacity     = 0
    read_capacity      = 0
    projection_type    = "KEYS_ONLY"
  }

}
