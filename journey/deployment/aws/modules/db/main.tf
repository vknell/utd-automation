############################################################################################
# Copyright 2020 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

data "aws_ami" "db_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "db" {
  ami           = "${data.aws_ami.db_ami.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"
  user_data = <<-EOF
            #!/bin/bash
            apt-get update
            apt-get install mariadb-server -y
            mysql -u root <<_EOF_
            CREATE DATABASE wordpress;
            CREATE USER 'pan_wpweb'@'localhost' IDENTIFIED BY 'paloalto2005';
            GRANT ALL PRIVILEGES ON wordpress.* TO 'pan_wpweb'@'localhost';
            CREATE USER 'pan_wpweb'@'10.5.2.5' IDENTIFIED BY 'paloalto2005';
            GRANT ALL PRIVILEGES ON wordpress.* TO 'pan_wpweb'@'10.5.2.5';
            FLUSH PRIVILEGES;
            exit
            _EOF_
            sed -i 's/127\.0\.0\.1/10\.5\.3\.5/g' /etc/mysql/mariadb.conf.d/50-server.cnf
            systemctl restart mysql
            ufw allow mysql
            EOF

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.db.id}"
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "aws_network_interface" "db" {
  subnet_id   = "${var.subnet_id}"
  private_ips = ["${var.private_ip}"]

  tags = "${merge(map("Name", format("%s-eth0", var.name)), var.tags)}"
}
