#######################################################################
## Required Variables                                                ##
#######################################################################

variable "ssh_key_name" {
  description = "SSH keypair name to provision firewall."
}

variable "vpc_id" {
  description = "VPC to create firewall instance in."
}

variable "fw_mgmt_sg_id" {
  description = "Security group for firewall management interface."
}

variable "fw_mgmt_subnet_id" {
  description = "Subnet ID for firewall management interface."
}

variable "fw_mgmt_ip" {
  description = "Internal IP address for firewall management interface."
}

variable "fw_dataplane_sg_id" {
  description = "Security group for firewall dataplane interfaces."
}

variable "fw_eth1_subnet_id" {
  description = "Subnet ID for firewall ethernet1/1."
}

variable "fw_eth2_subnet_id" {
  description = "Subnet ID for firewall ethernet1/2."
}

variable "fw_eth3_subnet_id" {
  description = "Subnet ID for firewall ethernet1/3."
}

#######################################################################
## Optional Variables                                                ##
#######################################################################

variable "name" {
  description = "Name of created instance.  Created resources will be prefixed with this string."
  default     = "Firewall"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "fw_instance_type" {
  description = "Instance type for firewall instance."
  default     = "m4.xlarge"
}

variable "fw_version" {
  description = "Firewall version to deploy."
  default     = "10.0"
}

# Firewall Product Code (Licensing Type)
## 9.0
# aws ec2 describe-images --filters "Name=product-code,Values=" Name=name,Values=PA-VM-AWS*9.0*  --region <region> --output json
# 6njl1pau431dv1qxipg63mvah = BYOL
# 6kxdw3bbmdeda3o6i1ggqt4km = Bundle 1
# 806j2of0qy5osgjjixq9gqc6g = Bundle 2
## 9.1
# aws ec2 describe-images --filters "Name=product-code,Values=" Name=name,Values=PA-VM-AWS*9.1*  --region <region> --output json
# 6njl1pau431dv1qxipg63mvah = BYOL
# e9yfvyj3uag5uo5j2hjikv74n = Bundle 1
# hd44w1chf26uv4p52cdynb2o = Bundle 2
## 10.0
# aws ec2 describe-images --filters "Name=product-code,Values=" Name=name,Values=PA-VM-AWS*10.0*  --region <region> --output json
# 6njl1pau431dv1qxipg63mvah = BYOL
# e9yfvyj3uag5uo5j2hjikv74n = Bundle 1
# hd44w1chf26uv4p52cdynb2o = Bundle 2

variable "fw_product_code" {
  default     = "hd44w1chf26uv4p52cdynb2o"
  description = "Product code for VM-series (Bundle 2)"
}

variable "fw_bootstrap_bucket" {
  description = "S3 bucket holding bootstrap configuration."
  default     = ""
}

variable "fw_eth1_ip" {
  description = " IP address for firewall ethernet1/1."
  default     = "10.5.1.4"
}

variable "fw_eth2_ip" {
  description = " IP address for firewall ethernet1/2."
  default     = "10.5.2.4"
}

variable "fw_eth3_ip" {
  description = " IP address for firewall ethernet1/3."
  default     = "10.5.3.4"
}
