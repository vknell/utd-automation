
variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "aws_az_name1" {
  description = "The AWS availability zone in which to deploy"
  type        = "string"
  default = "us-east-1a"
}

variable "aws_az_name2" {
  description = "The 2nd AWS AZ for the 2nd NGFW"
  default = "us-east-1b"
}

variable "web1_ip" {
  description = "Private ip of web1"
  type        = "string"
  default = "10.4.2.5"
}

variable "web2_ip" {
  description = "Private ip of web1"
  type        = "string"
  default = "10.4.46.5"
}

variable "sql1_ip" {
  description = "Private ip of 1 SQL"
  type        = "string"
  default = "10.4.1.5"
}

variable "sql2_ip" {
  description = "Private ip of 2 SQL"
  type        = "string"
  default = "10.4.45.5"
}

variable "mgmt_subnet_access" {
  description = "CIDR from access"
  type= "list"
  default = ["0.0.0.0/0"]
}

variable "public_key_file" {
  description = "Full path to the SSH public key file"
    default = "~/.ssh/lab_ssh_key.pub"
  type        = "string"
}

/*variable "Product_code" {
  type = "map"
  default =
    {
      "us-west-2"       =   "ami-d424b5ac",
      "ap-northeast-1"  =   "ami-57662d31",
      "us-west-1"       =   "ami-0d757d6f8dec81f7f",
      "ap-northeast-2"  =   "ami-49bd1127",
      "ap-southeast-1"  =   "ami-27baeb5b",
      "ap-southeast-2"  =   "ami-00d61562",
      "eu-central-1"    =   "ami-55bfd73a",
      "eu-west-1"       =   "ami-a95b4fc9",
      "eu-west-2"       =   "ami-876a8de0",
      "sa-east-1"       =   "ami-9c0154f0",
      "us-east-1"       =   "ami-a2fa3bdf",
      "us-east-2"       =   "ami-11e1d774",
      "ca-central-1"    =   "ami-64038400",
      "ap-south-1"      =   "ami-e780d988"
    }
}*/

variable "www_count" {
  description = "Number of firewall"
  default = "2"
}

# Using CentOS Product code
variable "centos_product_code7" {
  default = "aw0evgkw8e5c1q413zgy5pjce"
  description = "product code for centos7"
}

variable "centos_product_code6" {
  default = "6x5jmcajty9edm3f211pqjfn2"
  description = "product code for centos7"
}
