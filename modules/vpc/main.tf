
resource "aws_vpc" "vpc_transit" {
  cidr_block = "${var.cidr}"
  tags = {Name="VPC Transit"}
}
# Déclaration des subnet et de la table de routage du 1er firewall

resource "aws_subnet" "mgmt" {
  vpc_id            = "${aws_vpc.vpc_transit.id}"
  cidr_block        = "${var.mgmt_subnet}"
  availability_zone = "${var.az1}"

  tags = {Name="FW1_mgmt_subnet"}
}
resource "aws_subnet" "trust" {
  vpc_id            = "${aws_vpc.vpc_transit.id}"
  cidr_block        = "${var.trust_subnet}"
  availability_zone = "${var.az1}"

  tags = {Name="FW1_trust_subnet"}
}
resource "aws_subnet" "untrust" {
  vpc_id            = "${aws_vpc.vpc_transit.id}"
  cidr_block        = "${var.untrust_subnet}"
  availability_zone = "${var.az1}"

  tags = {Name="FW1_untrust_subnet"}
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_transit.id}"
}

resource "aws_route_table" "untrust" { 
  vpc_id = "${aws_vpc.vpc_transit.id}"
}
resource "aws_route" "untrust" { 
  route_table_id         = "${aws_route_table.untrust.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}
resource "aws_route_table_association" "mgmt" {
  subnet_id      = "${aws_subnet.mgmt.id}"
  route_table_id = "${aws_route_table.untrust.id}"
}

resource "aws_route_table_association" "untrust" {
  subnet_id      = "${aws_subnet.untrust.id}"
  route_table_id = "${aws_route_table.untrust.id}"
}

# Déclaration des subnets et des tables de routage du 2nd firewall
resource "aws_subnet" "mgmt2" {
  vpc_id            = "${aws_vpc.vpc_transit.id}"
  cidr_block        = "${var.mgmt_subnet2}"
  availability_zone = "${var.az2}"

  tags = {Name="FW2_mgmt_subnet"}
}

resource "aws_subnet" "trust2" {
  vpc_id            = "${aws_vpc.vpc_transit.id}"
  cidr_block        = "${var.trust_subnet2}"
  availability_zone = "${var.az2}"

  tags = {Name="FW2_trust_subnet"}
}

resource "aws_subnet" "untrust2" {
  vpc_id            = "${aws_vpc.vpc_transit.id}"
  cidr_block        = "${var.untrust_subnet2}"
  availability_zone = "${var.az2}"

  tags = {Name="FW2_untrust_subnet"}
}

resource "aws_route_table" "untrust2" {
  vpc_id = "${aws_vpc.vpc_transit.id}"
}

resource "aws_route" "untrust2" {
  route_table_id         = "${aws_route_table.untrust2.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "mgmt2" {
  subnet_id      = "${aws_subnet.mgmt2.id}"
  route_table_id = "${aws_route_table.untrust2.id}"
}

resource "aws_route_table_association" "untrust2" {
  subnet_id      = "${aws_subnet.untrust2.id}"
  route_table_id = "${aws_route_table.untrust2.id}"
}

#Déclaration du loadbalancer et de sa table de routage
#resource "aws_subnet" "lb" {
 # vpc_id = "${aws_vpc.vpc_transit.id}"
  #cidr_block        = "${var.load_balancer}"
  #availability_zone = "${var.az}"
  #tags = {Name="Load_balancer"}
#}
//resource "aws_route_table" "lb" {
  //vpc_id = "${aws_vpc.vpc.id}"
#}

//resource "aws_route" "lb" {
//  route_table_id         = "${aws_route_table.lb.id}"
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id             = "${aws_internet_gateway.igw.id}"
//}

//resource "aws_route_table_association" "lb" {
//  subnet_id      = "${aws_subnet.lb.id}"
//  route_table_id = "${aws_route_table.lb.id}"
//}

