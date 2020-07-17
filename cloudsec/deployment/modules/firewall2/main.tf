data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "fw2_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.fw2_version}*"]
  }

  filter {
    name   = "product-code"
    values = ["${var.fw2_product_code}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

resource "aws_instance" "fw2" {
  ami           = "${data.aws_ami.fw2_ami.id}"
  instance_type = "${var.fw2_instance_type}"
  key_name      = "${var.ssh_key_name}"

  disable_api_termination              = false #Permet de supp le fw depuis la console AWS
  instance_initiated_shutdown_behavior = "stop"

  ebs_optimized = true

  root_block_device {
    volume_type           = "gp2"
    delete_on_termination = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.fw2_eth2.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.fw2_mgmt.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.fw2_eth1.id}"
  }

  iam_instance_profile = "${aws_iam_instance_profile.fw2_bootstrap_instance_profile.name}"
  user_data            = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.fw2_bootstrap_bucket)))}"


    tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"

}

resource "aws_network_interface" "fw2_mgmt" {
  subnet_id       = "${var.fw2_mgmt_subnet_id}"
  private_ips     = ["${var.fw2_mgmt_ip}"]
  security_groups = ["${var.fw2_mgmt_sg_id}"]

  tags = {Name="mgmt2-Interface"}

}

resource "aws_network_interface" "fw2_eth1" {
  subnet_id         = "${var.fw2_eth1_subnet_id}"
  private_ips       = ["${var.fw2_eth1_ip}"]
  security_groups = ["${var.fw2_dataplane_sg_id}"]
  source_dest_check = false

  tags = {Name="trust2-Interface"}
}

resource "aws_network_interface" "fw2_eth2" {
  subnet_id         = "${var.fw2_eth2_subnet_id}"
  private_ips       = ["${var.fw2_eth2_ip}"]
  security_groups = ["${var.fw2_mgmt_sg_id}"]
  source_dest_check = false

  tags = {Name="untrust2-Interface"}
}
resource "aws_eip" "fw2_mgmt_eip" {
  vpc = true
  tags = {Name="EIP-mgmt2"}
}

resource "aws_eip_association" "fw2_mgmt_eip_assoc" {
  allocation_id        = "${aws_eip.fw2_mgmt_eip.id}"
  network_interface_id = "${aws_network_interface.fw2_mgmt.id}"
}

resource "aws_eip" "fw2_eth2_eip" {
  vpc = true

  tags = {Name="EIP-untrust2"}
}

resource "aws_eip_association" "fw2_eth2_eip_assoc" {
  allocation_id        = "${aws_eip.fw2_eth2_eip.id}"
  network_interface_id = "${aws_network_interface.fw2_eth2.id}"
}

resource "aws_iam_role" "fw2_bootstrap_role" {
  name = "Firewall2BootstrapRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "fw2_bootstrap_role_policy" {
  name = "Firewall2BootstrapRolePolicy"
  role = "${aws_iam_role.fw2_bootstrap_role.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.fw2_bootstrap_bucket}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.fw2_bootstrap_bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "fw2_bootstrap_instance_profile" {
  name = "Firewall2BootstrapInstanceProfile"
  role = "${aws_iam_role.fw2_bootstrap_role.name}"
  path = "/"
}
