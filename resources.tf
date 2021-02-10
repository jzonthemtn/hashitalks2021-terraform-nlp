resource "aws_sqs_queue" "queue" {
  name                       = "${var.name_prefix}-queue"
  delay_seconds              = 10
  max_message_size           = 2048
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60
}

resource "aws_s3_bucket" "bucket" {
  acl           = "private"
  force_destroy = true
}

# Upload a sample model to S3 to illustrate serving without having to
# spend time training a model.

#resource "aws_s3_bucket_object" "object-model" {
#  bucket = aws_s3_bucket.bucket.id
#  key    = "models/my-model/final-model.pt"
#  source = "my-model/final-model.pt"
#  etag = filemd5("my-model/final-model.pt")
#}

#resource "aws_s3_bucket_object" "object-weights" {
#  bucket = aws_s3_bucket.bucket.id
#  key    = "models/my-model/weights.txt"
#  source = "my-model/weights.txt"
#  etag = filemd5("my-model/weights.txt")
#}
