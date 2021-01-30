variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "nlp"
}

variable "availabilityZone" {
  default = "us-east-1a"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}

variable "subnetCIDRblock" {
  default = "10.0.1.0/24"
}

variable "subnet2CIDRblock" {
  default = "10.0.2.0/24"
}

variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}

variable "ingressCIDRblock" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "egressCIDRblock" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "mapPublicIP" {
  default = true
}

variable "ecs_cluster" {
  description = "ECS cluster name"
  default = "nlp-ecs"
}

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
  default = 1
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
  default = 1
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  default = 1
}
