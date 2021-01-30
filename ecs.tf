resource "aws_security_group" "ml_vpc_security_group" {
  vpc_id      = aws_vpc.ml_vpc.id
  name        = "ml-sg"
  description = "ml-sg"

  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "ml_vpc_gw" {
  vpc_id = aws_vpc.ml_vpc.id
  tags = {
    Name = "ml-igw"
  }
}

resource "aws_route_table" "ml_vpc_route_table" {
  vpc_id = aws_vpc.ml_vpc.id
  tags = {
    Name = "ml-route-table"
  }
}

resource "aws_route" "ml_vpc_internet_access" {
  route_table_id         = aws_route_table.ml_vpc_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.ml_vpc_gw.id
}

resource "aws_route_table_association" "ml_vpc_association" {
  subnet_id      = aws_subnet.ml_vpc_subnet.id
  route_table_id = aws_route_table.ml_vpc_route_table.id
}

#resource "aws_lambda_event_source_mapping" "example" {
#  event_source_arn = aws_sqs_queue.sqs_queue_test.arn
#  function_name    = aws_lambda_function.example.arn
#}

# ===

resource "aws_security_group" "ecs_sg" {
    vpc_id      = aws_vpc.ml_vpc.id

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

# =====

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

# ===

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-005b753c07ecef59f"
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config"
    instance_type        = "t3.large"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [aws_subnet.ml_vpc_subnet.id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

# ===

resource "aws_ecs_cluster" "ecs_cluster" {
    name  = var.cluster_name
}

# ===

data "template_file" "task_definition_template" {
  template = file("${path.module}/task_definition.json.tpl")
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "worker"
  container_definitions = data.template_file.task_definition_template.rendered
}

# ===

resource "aws_ecs_service" "serving" {
  name            = "serving"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
}
