resource "aws_sqs_queue" "ml_queue" {
  name                       = "ml-queue"
  delay_seconds              = 10
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60
}

output "queue_url" {
  value = aws_sqs_queue.ml_queue.id
}

resource "aws_s3_bucket" "ml-bucket" {
  acl = "private"
}

output "s3_bucket" {
  value = aws_s3_bucket.ml-bucket.id
}
