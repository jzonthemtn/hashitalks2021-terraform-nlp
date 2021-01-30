terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "ml_vpc_" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "ml-vpc"
  }
}

resource "aws_subnet" "ml_vpc_subnet" {
  vpc_id                  = aws_vpc.ml_vpc_.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "ml-subnet"
  }
}

resource "aws_security_group" "ml_vpc_security_group" {
  vpc_id      = aws_vpc.ml_vpc_.id
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
  vpc_id = aws_vpc.ml_vpc_.id
  tags = {
    Name = "ml-igw"
  }
}

resource "aws_route_table" "ml_vpc_route_table" {
  vpc_id = aws_vpc.ml_vpc_.id
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
