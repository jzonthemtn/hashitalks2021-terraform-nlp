resource "aws_sqs_queue" "queue" {
  name                       = "${var.name_prefix}-queue"
  delay_seconds              = 10
  max_message_size           = 2048
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60
}

resource "aws_s3_bucket" "bucket" {
  acl = "private"
}