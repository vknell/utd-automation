variable "ssh_key_name" {}

variable "subnet1_id" {}

variable "subnet2_id" {}

variable "private_ip1" {}

variable "private_ip2" {
  
}


variable "name" {
  default = "Web"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}