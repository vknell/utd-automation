output "instance2_id" {
  value = "${aws_instance.fw2.id}"
}

output "fw2_mgmt_ip" {
  value = "${var.fw2_mgmt_ip}"
}

output "fw2_mgmt_eip" {
  value = "${aws_eip.fw2_mgmt_eip.public_ip}"
}

output "fw2_mgmt_if_id" {
  value = "${aws_network_interface.fw2_mgmt.id}"
}

output "fw2_eth2_eip" {
  value = "${aws_eip.fw2_eth2_eip.public_ip}"
}

output "fw2_eth1_id" {
  value = "${aws_network_interface.fw2_eth2.id}"
}


