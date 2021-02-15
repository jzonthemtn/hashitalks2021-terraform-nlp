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

data "aws_ssm_parameter" "subnet1" {
  name = "${var.name_prefix}-subnet1"
}

data "aws_ssm_parameter" "subnet2" {
  name = "${var.name_prefix}-subnet2"
}

data "aws_ssm_parameter" "vpc" {
  name = "${var.name_prefix}-vpc"
}

resource "aws_ecs_service" "service" {
  name                = "${var.name_prefix}-${var.model_key}-serving"
  cluster             = data.aws_ssm_parameter.cluster.value
  desired_count       = var.desired_count
  task_definition     = aws_ecs_task_definition.app.arn
  scheduling_strategy = "REPLICA"

  # 50 percent must be healthy during deploys
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = "${var.name_prefix}-${var.model_key}-serving"
    container_port   = 8080
  }
}

data "template_file" "task_definition" {
  template = file("${path.module}/app.json")

  vars = {
    bucket    = data.aws_ssm_parameter.bucket_name.value
    key       = var.model_key
    name      = "${var.name_prefix}-${var.model_key}-serving"
    log_group = "${var.name_prefix}-${var.model_key}-serving"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "${var.name_prefix}-${var.model_key}-serving"
  container_definitions = data.template_file.task_definition.rendered
  task_role_arn         = aws_iam_role.task_role.arn
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

resource "aws_security_group" "alb_security_group" {
  vpc_id = data.aws_ssm_parameter.vpc.value
  name   = "${var.name_prefix}-${var.model_key}-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "nlp_serving_alb" {
  name            = "${var.name_prefix}-${var.model_key}-serving-alb"
  subnets         = [data.aws_ssm_parameter.subnet1.value, data.aws_ssm_parameter.subnet2.value]
  security_groups = [aws_security_group.alb_security_group.id]
  enable_http2    = false
  idle_timeout    = 600
}

output "alb_output" {
  value = aws_alb.nlp_serving_alb.dns_name
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.nlp_serving_alb.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "target_group" {
  name       = "${var.name_prefix}-${var.model_key}-serving-gp"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = data.aws_ssm_parameter.vpc.value
  depends_on = [aws_alb.nlp_serving_alb]

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
  }
}
