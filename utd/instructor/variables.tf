variable "instance_count" {
  description = "number of instances to create"
  default = "5"
}

variable "instance_type" {
  description = "Server size on AWS, lower is cheaper"
  # default = "t2.micro"
  # default = "t2.small"
  default = "t2.medium"
}

variable "aws_region" {
  description = "describe your variable"
  default = "default_value"
}

variable "aws_az" {
  description = "describe your variable"
  default = "default_value"
}

variable "name" {
  type = "string"
  description = "describe your variable"
  default = "default_value"

variable "name" {
  type = "string"
  description = "describe your variable"
  default = "default_value"
}