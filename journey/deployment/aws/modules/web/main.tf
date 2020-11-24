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

data "aws_ami" "web_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.web_ami.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"

  user_data = <<-EOF
            #!/bin/bash
            # check for internet connectivity
            while true
              do
                resp=$(curl -s -S "http://captive.apple.com")
                echo $resp
                if [[ $resp == *"Success"* ]] ; then
                  break
                fi
                sleep 10s
              done
            # launch the startup script
            apt-get update
            apt-get install apache2 php libapache2-mod-php mariadb-client php-mysql -y
            echo "Pew Pew Pew" > /var/www/html/index.html
            wget https://wordpress.org/latest.tar.gz
            tar -xzf latest.tar.gz -C /var/www/html/
            cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
            sed -i 's/database_name_here/wordpress/g' /var/www/html/wordpress/wp-config.php
            sed -i 's/pan_wpweb/wordpress/g' /var/www/html/wordpress/wp-config.php
            sed -i 's/paloalto2005/wordpress/g' /var/www/html/wordpress/wp-config.php
            sed -i 's/10\.5\.2\.5/wordpress/g' /var/www/html/wordpress/wp-config.php
            chown -R www-data:www-data /var/www/html/
            systemctl restart apache2
            EOF

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.web.id}"
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "aws_network_interface" "web" {
  subnet_id   = "${var.subnet_id}"
  private_ips = ["${var.private_ip}"]

  tags = "${merge(map("Name", format("%s-eth0", var.name)), var.tags)}"
}
