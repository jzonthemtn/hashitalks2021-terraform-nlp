resource "aws_sqs_queue" "ml_queue" {
  name                      = "ml-queue"
  delay_seconds             = 10
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_s3_bucket" "ml-bucket" {
  acl    = "private"
}
