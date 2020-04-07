provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "vpc_utd" {
  cidr_block = "10.99.0.0/24"
  tags = {
    Name = "utd-auto-vpc"
  }
}

resource "aws_subnet" "subnet_utd_mgmt" {
  availability_zone = "eu-west-3a"
  cidr_block = "10.99.0.0/24"
  ipv6_cidr_block = "Optional"
  map_public_ip_on_launch = "Optional"
  assign_ipv6_address_on_creation = "Optional"
  vpc_id = ""
  tags = {
    Name = "subnet-utd-mgmt"
  }
}

resource "aws_key_pair" "keypair_utd" {
  key_name = "utd-automation"
  public-key = "${file(var.public_key_file)}"
  tags = {
    Name = "keypair-utd"
  }
}

resource "aws_security_group" "sg_utd" {
  name = "utd-auto-sg"
  ingress {
    to_port = 
  }
  egress = "Optional"
  revoke_rules_on_delete = "Optional"
  vpc_id = "Optional"
  tags = "Optional"
}

resource "aws_instance" "ec2-utd" {
  ami = "ami-096b8af6e7e8fb927"
  instance_type = "${var.instance_type}"
  instance_count = "${var.instance_count}"

  user_data = "${file("ubuntu.cfg")}"
  tags = {
    Name = "utd-automation"
  }
}
