provider "aws" { # Définition du provider
  region  = "${var.aws_region}" # Variable Région AWS
  version = "2.7"
}
module "bootstrap_bucket" { #Bootstrap configuration
  source = "./modules/bootstrap" 
  bootstrap_xml_path      = "./common/bootstrap/config/bootstrap.xml"
  bootstrap_init_cfg_path = "./common/bootstrap/config/init-cfg.txt"
}
module "vpc_transit" { #module VPC
  source = "./modules/vpc" #Module Path
  name = "Transit"
  cidr = "10.5.0.0/16" #Subnet du VPC
  az1   = "${var.aws_az_name1}" # Avaibility Zone 1
  az2  = "${var.aws_az_name2}" # Avaibility Zone 2

  # Subnets du 1ere firewall
  mgmt_subnet   = "10.5.0.0/24" 
  trust_subnet = "10.5.1.0/24"
  untrust_subnet   = "10.5.2.0/24"
  # Subnet du 2nd firewall
  mgmt_subnet2 = "10.5.45.0/24"
  trust_subnet2 = "10.5.46.0/24"
  untrust_subnet2 = "10.5.47.0/24"

  tags = {
    Environment = "transitvpc"
  }
}

module "vpc_client" { #module VPC
  source = "./modules/vpc_client" #Module Path
  name = "client"
  cidr = "10.4.0.0/16" #Subnet du VPC
  az1   = "${var.aws_az_name1}" # Avaibility Zone def
  az2   ="${var.aws_az_name2}"
  # Subnets du sql
  sql_sub1 = "10.4.1.0/24"
  sql_sub2= "10.4.45.0/24"
  # Subnets web
  web_sub1 = "10.4.2.0/24"
  web_sub2="10.4.46.0/24"

  ip_fw1 ="${module.firewall.fw_eth2_eip}"
  ip_fw2="${module.firewall2.fw2_eth2_eip}"

  tags = {
    Environment = "web"
  }
}
module "firewall" { # Déclaration du module 1er firewall
  source = "./modules/firewall"
  name = "Firewall-1"
  ssh_key_name = "${aws_key_pair.ssh_key.key_name}" # SSH Key for auth
  vpc_id       = "${module.vpc_transit.vpc_id}"

  fw_mgmt_subnet_id = "${module.vpc_transit.mgmt_subnet_id}"
  fw_mgmt_ip        = "10.5.0.4" # Private IP
  fw_mgmt_sg_id     = "${aws_security_group.firewall_mgmt_sg.id}" # Security Group public

  fw_eth1_subnet_id = "${module.vpc_transit.trust_subnet_id}"
  fw_eth2_subnet_id = "${module.vpc_transit.untrust_subnet_id}"

  fw_dataplane_sg_id = "${aws_security_group.public_sg.id}" # Security Group public

  fw_version          = "8.1"
  fw_product_code     = "806j2of0qy5osgjjixq9gqc6g"
  fw_bootstrap_bucket = "${module.bootstrap_bucket.bootstrap_bucket_name}" # Spécification du bootsrap à utiliser

  tags = {
    Environment = "NGFW"
  }

}

module "firewall2" { # Déclaration du module 2nd firewall
  source = "./modules/firewall2"

  name = "Firewall-2"

  ssh_key_name = "${aws_key_pair.ssh_key.key_name}"
  vpc_id       = "${module.vpc_transit.vpc_id}"

  fw2_mgmt_subnet_id = "${module.vpc_transit.mgmt_subnet_id2}"
  fw2_mgmt_ip        = "10.5.45.4"
  fw2_mgmt_sg_id     = "${aws_security_group.firewall_mgmt_sg.id}"

  fw2_eth1_subnet_id = "${module.vpc_transit.trust_subnet_id2}"
  fw2_eth2_subnet_id = "${module.vpc_transit.untrust_subnet_id2}"

  fw2_dataplane_sg_id = "${aws_security_group.public_sg.id}"

  fw2_version          = "9.0"
  fw2_product_code     = "806j2of0qy5osgjjixq9gqc6g"
  fw2_bootstrap_bucket = "${module.bootstrap_bucket.bootstrap_bucket_name}"

  tags = {
    Environment = "NGFW"
  }

}

module "loadbalancer" {
  source ="/modules/loadbalancer"
  name = "lb1"
}
resource "aws_security_group" "public_sg" { # Règle de sécurité pour accès au réseau
  name        = "Public Security Group"
  description = "Wide open security group"
  vpc_id      = "${module.vpc_transit.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
resource "aws_security_group" "firewall_mgmt_sg" { # SG MGMT firewall
  name        = "FirewallMgmtSG"
  description = "Firewall Management Security Group"
  vpc_id      = "${module.vpc_transit.vpc_id}"

  ingress {
    to_port     = "22"
    from_port   = "22"
    protocol    = "tcp"
    cidr_blocks = "${var.mgmt_subnet_access}"
  }

  ingress {
    to_port     = "443"
    from_port   = "443"
    protocol    = "tcp"
    cidr_blocks = "${var.mgmt_subnet_access}"
  }

  ingress {
    to_port     = "0"
    from_port   = "8"
    protocol    = "icmp"
    cidr_blocks = "${var.mgmt_subnet_access}"
  }

  ingress {
    to_port = "80"
    from_port = "80"
    protocol = "tcp"
    cidr_blocks = "${var.mgmt_subnet_access}"
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


module "web" { #Déclaration du module du service web
  source = "./modules/web"

  name         = "web-vm"
  ssh_key_name = "${aws_key_pair.ssh_key.key_name}"
  
  //product_code = "${var.centos_product_code7}"

  subnet_id1  = "${module.vpc_client.web1}"
  subnet_id2  = "${module.vpc_client.web2}"

  private_ip1 = "${var.web1_ip}"
  private_ip2 = "${var.web2_ip}"

  tags = {
    Environment = "automation"
    server-type = "web"
  }
}


module "sql" { #Déclaration du module du service sql
  source = "./modules/sql"
  name         = "sql-vm"
  ssh_key_name = "${aws_key_pair.ssh_key.key_name}"

  subnet1_id  = "${module.vpc_client.sql1}"
  subnet2_id  = "${module.vpc_client.sql2}"

  private_ip1 = "${var.sql1_ip}"
  private_ip2 = "${var.sql2_ip}"

  tags = {
    Environment = "automation"
    server-type = "sql"
  }
}

module "vpn" {
  source ="./modules/vpn"
  name  ="vpn-transit"

  ssh_key_name ="${aws_key_pair.ssh_key.key_name}"

  vpc_client_id="${module.vpc_client.vpc_client_id}"
  public_ip_fw1="${module.firewall.fw_eth2_eip}"
  public_ip_fw2="${module.firewall2.fw2_eth2_eip}"
  route_table_id="${module.vpc_client.route_table_id}"

  tags = {
    Environment = "VPN Transit"
  }
}