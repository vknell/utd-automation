variable "instance_count" {
  description = "number of instances to create"
  default = "5"
}

variable "instance_type" {
  description = "describe your variable"
  default = "t2.medium"
}

variable "aws_region" {
  description = "describe your variable"
  default = "default_value"
}

variable "name" {
  type = "string"
  description = "describe your variable"
  default = "default_value"
}