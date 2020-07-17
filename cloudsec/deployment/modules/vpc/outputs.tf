
output "name" {
  value = "${var.name}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_transit.id}"
}

output vpc_cidr_block {
  value = "${aws_vpc.vpc_transit.cidr_block}"
}

# 1er Firewall
output "mgmt_subnet_id" {
  value = "${aws_subnet.mgmt.id}"
}
output "mgmt_subnet_id2" {
  value = "${aws_subnet.mgmt2.id}"
}

output "trust_subnet_id" {
  value = "${aws_subnet.trust.id}"
}
output "trust_subnet_id2" {
  value = "${aws_subnet.trust2.id}"
}

output "untrust_subnet_id" {
  value = "${aws_subnet.untrust.id}"
}
output "untrust_subnet_id2" {
  value = "${aws_subnet.untrust2.id}"
}