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

resource "aws_vpc" "ml_vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "ml-vpc"
  }
}

resource "aws_subnet" "ml_vpc_subnet" {
  vpc_id                  = aws_vpc.ml_vpc.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "ml-subnet-1"
  }
}

resource "aws_subnet" "ml_vpc_subnet_2" {
  vpc_id                  = aws_vpc.ml_vpc.id
  cidr_block              = var.subnet2CIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "ml-subnet-2"
  }
}

resource "aws_sqs_queue" "ml_queue" {
  name                       = "ml-queue"
  delay_seconds              = 10
  max_message_size           = 2048
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60
}

output "queue_url" {
  value = aws_sqs_queue.ml_queue.id
}

resource "aws_s3_bucket" "ml_bucket" {
  acl = "private"
}

output "s3_bucket" {
  value = aws_s3_bucket.ml_bucket.id
}
