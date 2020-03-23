variable "name" {
  description = "Name of the created VPC.  Created resources will be prefixed with this string."
}

variable "az1" {
  description = "The first AWS availability zone deployment"
}

variable "az2" {
  description ="The second AWS Availability zone deployment"
}

variable "cidr" {
  description = "CIDR range for created VPC."
}

# variables VPC client
variable "sql_sub1" {
  description = "SQL subnet address range."
}

variable "web_sub1" {
  description = "WEB subnet address range."
}

variable "sql_sub2" {
  description = "SQL subnet address range."
}
variable "web_sub2" {
  description = "WEB subnet address range."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "ip_fw1" {
  description ="fw eip1 for vpn customer"
}

variable "ip_fw2" {
  description="fw eip2 for vpn customer"
}


# variables laodbalancer et service web
/*variable "load_balancer" {
  description = "Load balancer subnet adress range."
}
*/
