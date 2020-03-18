# Récupération des données d'un serveur web existant
data "aws_ami" "web_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["multicloud-aws-web-*"]
  }

  owners = ["640680520898"]
}

# Création de l'instance du serveur web
resource "aws_instance" "web1" {
  ami           = "${data.aws_ami.web_ami.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.web1.id}"
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "aws_instance" "web2" {
  ami           = "${data.aws_ami.web_ami.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.web2.id}"
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

# Création de l'interface du serveur web
resource "aws_network_interface" "web1" {
  subnet_id   = "${var.subnet_id1}"
  private_ips = ["${var.private_ip1}"]

  tags = {Name="web-Interface1"}
}

resource "aws_network_interface" "web2" {
  subnet_id   = "${var.subnet_id2}"
  private_ips = ["${var.private_ip2}"]

  tags = {Name="web-Interface2"}
}
