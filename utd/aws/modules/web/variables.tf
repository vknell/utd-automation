variable "ssh_key_name" {}

variable "subnet_id1" {}

variable "subnet_id2" {}

variable "private_ip1" {}

variable "private_ip2" {}

variable "name" {
  default = "SQL"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}