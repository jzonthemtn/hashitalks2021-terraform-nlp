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

resource "aws_vpc" "ml_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "ml_vpc_subnet" {
  vpc_id                  = aws_vpc.ml_vpc.id
  cidr_block              = var.subnet_1_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_1
  tags = {
    Name = "${var.name_prefix}-subnet-1"
  }
}

resource "aws_subnet" "ml_vpc_subnet_2" {
  vpc_id                  = aws_vpc.ml_vpc.id
  cidr_block              = var.subnet_2_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_2
  tags = {
    Name = "${var.name_prefix}-subnet-2"
  }
}
