output "queue_url" {
  value = aws_sqs_queue.queue.id
}

output "s3_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "ml_vpc_subnet_id" {
  value = aws_subnet.ml_vpc_subnet.id
}

output "ml_vpc_subnet2_id" {
  value = aws_subnet.ml_vpc_subnet_2.id
}

output "ecs_cluster_name" {
  value = "${var.name_prefix}-ecs"
}

output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}
