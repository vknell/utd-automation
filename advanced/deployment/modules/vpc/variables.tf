variable "name" {
  description = "Name of the created VPC.  Created resources will be prefixed with this string."
}

variable "az1" {
  description = "The AWS availability zone in which to deploy"
}
variable "az2" {
  description = "The AWS availability zone in which to deploy"
}
variable "cidr" {
  description = "CIDR range for created VPC."
}

# varianbles 1er firewall
variable "mgmt_subnet" {
  description = "Management subnet address range."
}

variable "trust_subnet" {
  description = "Trust subnet address range."
}

variable "untrust_subnet" {
  description = "Untrust subnet address range."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

# variables 2nd firewall
variable "mgmt_subnet2" {
  description = "Management subnet address range."
}

variable "trust_subnet2" {
  description = "Trust subnet address range."
}

variable "untrust_subnet2" {
  description = "Untrust subnet address range."
}

