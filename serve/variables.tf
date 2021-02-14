variable "region" {
  default = "us-east-1"
}

variable "name_prefix" {
  default = "nlp-ner"
}

variable "model_key" {
  default = "my-model"
}

variable "desired_count" {
  description = "desired number of tasks to run"
  default     = "1"
}
