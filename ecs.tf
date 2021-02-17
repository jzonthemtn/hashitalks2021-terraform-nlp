resource "aws_security_group" "ml_vpc_security_group" {
  vpc_id = aws_vpc.ml_vpc.id
  name   = "${var.name_prefix}-sg"

  ingress {
    cidr_blocks = var.ingress_cidr_block
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

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

resource "aws_internet_gateway" "ml_vpc_gw" {
  vpc_id = aws_vpc.ml_vpc.id
  tags = {
    Name = "ml-igw"
  }
}

resource "aws_route_table" "ml_vpc_route_table" {
  vpc_id = aws_vpc.ml_vpc.id
  tags = {
    Name = "${var.name_prefix}-route-table"
  }
}

resource "aws_route" "ml_vpc_internet_access" {
  route_table_id         = aws_route_table.ml_vpc_route_table.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.ml_vpc_gw.id
}

resource "aws_route_table_association" "ml_vpc_association" {
  subnet_id      = aws_subnet.ml_vpc_subnet.id
  route_table_id = aws_route_table.ml_vpc_route_table.id
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.ml_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "task_policy" {
  name        = "${var.name_prefix}-task-policy"
  description = "IAM policy for ECS tasks"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect":"Allow",
       "Action":["s3:ListBucket"],
       "Resource":"arn:aws:s3:::${aws_s3_bucket.bucket.id}"
    },
    {
       "Effect":"Allow",
       "Action":["s3:PutObject"],
       "Resource":"arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
    },
    {
        "Sid": "ListAndDescribe",
        "Effect": "Allow",
        "Action": [
            "dynamodb:List*",
            "dynamodb:DescribeReservedCapacity*",
            "dynamodb:DescribeLimits",
            "dynamodb:DescribeTimeToLive"
        ],
        "Resource": "*"
    },
    {
        "Sid": "SpecificTable",
        "Effect": "Allow",
        "Action": [
            "dynamodb:*"
        ],
        "Resource": "${aws_dynamodb_table.models_dynamodb_table.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "task_role" {
  name = "${var.name_prefix}-task-role"

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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}

resource "aws_iam_role" "ecs_agent" {
  name               = "${var.name_prefix}-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${var.name_prefix}-ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-005b753c07ecef59f"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=nlp-ner-ecs >> /etc/ecs/ecs.config"
  instance_type        = var.ec2_instance_type
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                 = "${var.name_prefix}-ecs-asg"
  vpc_zone_identifier  = [aws_subnet.ml_vpc_subnet.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = var.desired_capacity
  min_size                  = var.min_cluster_size
  max_size                  = var.max_cluster_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}-ecs"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
