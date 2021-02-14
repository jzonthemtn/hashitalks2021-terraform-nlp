terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ssm_parameter" "cluster" {
  name = "${var.name_prefix}-ecs-cluster-name"
}

data "aws_ssm_parameter" "bucket_name" {
  name = "${var.name_prefix}-s3-bucket"
}

#resource "aws_security_group_rule" "example" {
#  type              = "ingress"
#  from_port         = 0
#  to_port           = 65535
#  protocol          = "tcp"
#  cidr_blocks       = [aws_vpc.example.cidr_block]
#  security_group_id = "sg-123456"
#}

resource "aws_ecs_service" "service" {
  name                = "${var.name_prefix}-${var.model_key}-serving"
  cluster             = data.aws_ssm_parameter.cluster.value
  desired_count       = var.desired_count
  task_definition     = aws_ecs_task_definition.app.arn
  scheduling_strategy = "REPLICA"

  # 50 percent must be healthy during deploys
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  #load_balancer {
  #  target_group_arn = var.target_group_arn
  #  container_name   = "${var.name_prefix}-${model_key}-serving"
  #  container_port   = var.container_port
  #}
}

data "template_file" "task_definition" {
  template = file("${path.module}/app.json")

  vars = {
    bucket = data.aws_ssm_parameter.bucket_name.value
    key    = var.model_key
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "${var.name_prefix}-${var.model_key}-serving"
  container_definitions = data.template_file.task_definition.rendered
  task_role_arn = aws_iam_role.task_role.arn
}

resource "aws_cloudwatch_log_group" "nlp-serving" {
  name = "${var.name_prefix}-${var.model_key}-serving"
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}

resource "aws_iam_role" "task_role" {
  name = "${var.name_prefix}-serving-task-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "task_policy" {
  name        = "${var.name_prefix}-serving-task-policy"
  description = "IAM policy for ECS tasks"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect":"Allow",
       "Action":["s3:ListBucket"],
       "Resource":"arn:aws:s3:::${data.aws_ssm_parameter.bucket_name.value}"
    },
    {
       "Effect":"Allow",
       "Action":["s3:*"],
       "Resource":"arn:aws:s3:::${data.aws_ssm_parameter.bucket_name.value}/*"
    }
  ]
}
EOF
}
