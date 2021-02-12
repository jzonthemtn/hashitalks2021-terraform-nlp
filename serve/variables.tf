variable "name_prefix" {
  default = "nlp-ner"
}

variable "bucket_name" {
  default = "terraform-20210212135933787000000001"
}

variable "model_key" {
  default = "nlp-ner"
}

variable "vpc_name" {
  default = "nlp-ner-vpc"
}

variable "cluster" {
  default = "nlp-ner-ecs"
}

variable "desired_count" {
  description = "desired number of tasks to run"
  default     = "1"
}
