data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "fw_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.fw_version}*"]
  }

  filter {
    name   = "product-code"
    values = ["${var.fw_product_code}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

# Définition du firewall
resource "aws_instance" "fw" {
  ami           = "${data.aws_ami.fw_ami.id}"
  instance_type = "${var.fw_instance_type}"
  key_name      = "${var.ssh_key_name}"

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"

  ebs_optimized = true

  root_block_device {
    volume_type           = "gp2"
    delete_on_termination = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.fw_eth2.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.fw_mgmt.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.fw_eth1.id}"
  }

  # Ajout du profil de bootstrap
  iam_instance_profile = "${aws_iam_instance_profile.fw_bootstrap_instance_profile.name}"
  user_data            = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.fw_bootstrap_bucket)))}"

    tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"

}

# Déclaration des différentes interfaces : mgmt, eth1 , eth2, eth3
resource "aws_network_interface" "fw_mgmt" {
  subnet_id       = "${var.fw_mgmt_subnet_id}"
  private_ips     = ["${var.fw_mgmt_ip}"]
  security_groups = ["${var.fw_mgmt_sg_id}"]

  tags = {Name="mgmt-Interface"}
}

resource "aws_network_interface" "fw_eth1" {
  subnet_id         = "${var.fw_eth1_subnet_id}"
  private_ips       = ["${var.fw_eth1_ip}"]
  security_groups = ["${var.fw_dataplane_sg_id}"]
  source_dest_check = false

  tags = {Name="trust-Interface"}
}

resource "aws_network_interface" "fw_eth2" {
  subnet_id         = "${var.fw_eth2_subnet_id}"
  private_ips       = ["${var.fw_eth2_ip}"]
  security_groups = ["${var.fw_mgmt_sg_id}"]
  source_dest_check = false

  tags = {Name="untrust-Interface"}
}

# Permet de préciser que l'Elastic IP du mgmt se trouve dans le VPC
resource "aws_eip" "fw_mgmt_eip" {
  vpc = true
  tags = {Name="EIP-mgmt-FW1"}
}

# Association de l'Elastic IP à l'interface de mgmt
resource "aws_eip_association" "fw_mgmt_eip_assoc" {
  allocation_id        = "${aws_eip.fw_mgmt_eip.id}"
  network_interface_id = "${aws_network_interface.fw_mgmt.id}"
}

# Elastic IP de eth2 se trouve dans le VPC
resource "aws_eip" "fw_eth2_eip" {
  vpc = true
  tags ={Name="EIP-untrust-FW1"}
}

# Association de l'Elastic IP à l'interface eth2
resource "aws_eip_association" "fw_eth2_eip_assoc" {
  allocation_id        = "${aws_eip.fw_eth2_eip.id}"
  network_interface_id = "${aws_network_interface.fw_eth2.id}"
}

# Donne l'accès à l'EC2 d'exécuter des actions
resource "aws_iam_role" "fw_bootstrap_role" {
  name = "FirewallBootstrapRole"

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

# Action que l'EC2 doit faire
resource "aws_iam_role_policy" "fw_bootstrap_role_policy" {
  name = "FirewallBootstrapRolePolicy"
  role = "${aws_iam_role.fw_bootstrap_role.id}"

  # Liste des actions que l'EC2 se trouve dans la variables fw_bootstrap_bucket
  # Va récuperer les éléments se trouvant dans la liste
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    { 
      "Effect": "Allow",
      "Action": "s3:ListBucket", 
      "Resource": "arn:aws:s3:::${var.fw_bootstrap_bucket}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.fw_bootstrap_bucket}/*"
    }
  ]
} 
EOF
}

# Le role et la regle sont attachés au profil de bootstrap
resource "aws_iam_instance_profile" "fw_bootstrap_instance_profile" {
  name = "FirewallBootstrapInstanceProfile"
  role = "${aws_iam_role.fw_bootstrap_role.name}"
  path = "/"
}

