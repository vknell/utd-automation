variable "ssh_key_name" {
  description = "SSH keypair name to provision firewall."
}

variable "vpc_id" {
  description = "VPC to create firewall instance in."
}

variable "fw_mgmt_subnet_id" {
  description = "Subnet ID for firewall management interface."
}

variable "fw_mgmt_ip" {
  description = "Internal IP address for firewall management interface."
}

variable "fw_eth1_subnet_id" {
  description = "Subnet ID for firewall ethernet1/1."
}

variable "fw_eth2_subnet_id" {
  description = "Subnet ID for firewall ethernet1/2."
}

variable "name" {
  description = "Name of created instance.  Created resources will be prefixed with this string."
  default     = "Firewall"
}

variable "fw_instance_type" {
  description = "Instance type for firewall instance."
  default     = "m4.xlarge"
}

variable "fw_version" {
  description = "Firewall version to deploy."
  default     = "8.1"
}

variable "fw_bootstrap_bucket" {
  description = "S3 bucket holding bootstrap configuration."
  default     = ""
}

/*variable "fw_product_code" {
  default     = "6njl1pau431dv1qxipg63mvah"
  description = "Product code for VM-series (BYOL, Bundle 1, Bundle 2)"
}*/

variable "fw_product_code" {
  default   = "6kxdw3bbmdeda3o6i1ggqt4km"
  description ="product code for VM-Series Bundle 1"
}

variable "fw_eth1_ip" {
  description = " IP address for firewall ethernet1/1."
  default     = "10.5.1.4"
}
variable "fw_eth2_ip" {
  description = " IP address for firewall ethernet1/2."
  default     = "10.5.2.4"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "fw_dataplane_sg_id" {
  description = "Security group for firewall dataplane interfaces."
}

variable "fw_mgmt_sg_id" {
  description = "Security group for firewall management interface."
}
