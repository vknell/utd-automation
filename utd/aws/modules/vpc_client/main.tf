
resource "aws_vpc" "vpc_client" {
  cidr_block = "${var.cidr}"
  tags = {Name="VPC Prod"}
}
# Déclaration des subnet et de la table de routage du 1er firewall
resource "aws_subnet" "web1" {
  vpc_id = "${aws_vpc.vpc_client.id}"
  cidr_block        = "${var.web_sub1}"
  availability_zone = "${var.az1}"
  tags = {Name="Web-AZ1"}
}
resource "aws_subnet" "web2" {
  vpc_id = "${aws_vpc.vpc_client.id}"
  cidr_block        = "${var.web_sub2}"
  availability_zone = "${var.az2}"
  tags = {Name="Web-AZ2"}
}
resource "aws_subnet" "sql1" {
  vpc_id            = "${aws_vpc.vpc_client.id}"
  cidr_block        = "${var.sql_sub1}"
  availability_zone = "${var.az1}"
  tags = {Name="SQL-AZ1"}
}
resource "aws_subnet" "sql2" {
  vpc_id            = "${aws_vpc.vpc_client.id}"
  cidr_block        = "${var.sql_sub2}"
  availability_zone = "${var.az2}"
  tags = {Name="SQL-AZ2"}
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_client.id}"
}
resource "aws_route_table" "VPN" { 
  vpc_id = "${aws_vpc.vpc_client.id}"
}
resource "aws_route" "VPN" { 
  route_table_id         = "${aws_route_table.VPN.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}
resource "aws_route_table_association" "web1" {
  subnet_id      = "${aws_subnet.web1.id}"
  route_table_id = "${aws_route_table.VPN.id}"
}
resource "aws_route_table_association" "web2" {
  subnet_id      = "${aws_subnet.web2.id}"
  route_table_id = "${aws_route_table.VPN.id}"
}
resource "aws_route_table_association" "sql1" {
  subnet_id      = "${aws_subnet.sql1.id}"
  route_table_id = "${aws_route_table.VPN.id}"
}
resource "aws_route_table_association" "sql2" {
  subnet_id      = "${aws_subnet.sql2.id}"
  route_table_id = "${aws_route_table.VPN.id}"
}


# Déclaration des subnets et des tables de routage du 2nd firewall

#Déclaration du loadbalancer et de sa table de routag

