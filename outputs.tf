output "queue_url" {
  value = aws_sqs_queue.queue.id
}

output "s3_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "ml_vpc_subnet_id" {
  value = aws_subnet.ml_vpc_subnet.id
}

resource "aws_ssm_parameter" "param_subnet1" {
  name  = "${var.name_prefix}-subnet1"
  type  = "String"
  value = aws_subnet.ml_vpc_subnet.id
}

output "ml_vpc_subnet2_id" {
  value = aws_subnet.ml_vpc_subnet_2.id
}

resource "aws_ssm_parameter" "param_subnet2" {
  name  = "${var.name_prefix}-subnet2"
  type  = "String"
  value = aws_subnet.ml_vpc_subnet_2.id
}

output "ecs_cluster_name" {
  value = "${var.name_prefix}-ecs"
}

output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}

resource "aws_ssm_parameter" "param_ecs_cluster_name" {
  name  = "${var.name_prefix}-ecs-cluster-name"
  type  = "String"
  value = "${var.name_prefix}-ecs"
}

resource "aws_ssm_parameter" "param_s3_bucket" {
  name  = "${var.name_prefix}-s3-bucket"
  type  = "String"
  value = aws_s3_bucket.bucket.id
}

resource "aws_ssm_parameter" "param_ecs_sg" {
  name  = "${var.name_prefix}-ecs-sg"
  type  = "String"
  value = aws_security_group.ecs_sg.id
}

resource "aws_ssm_parameter" "param_vpc" {
  name  = "${var.name_prefix}-vpc"
  type  = "String"
  value = aws_vpc.ml_vpc.id
}
