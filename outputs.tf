output "queue_url" {
  value = aws_sqs_queue.queue.id
}

output "s3_bucket" {
  value = aws_s3_bucket.bucket.id
}
