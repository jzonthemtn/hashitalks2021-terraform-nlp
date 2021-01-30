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
