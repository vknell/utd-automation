output "instance_id" {
  value = "${aws_instance.fw.id}"
}
output "fw_mgmt_ip" {
  value = "${var.fw_mgmt_ip}"
}
output "fw_mgmt_eip" {
  value = "${aws_eip.fw_mgmt_eip.public_ip}"
}

output "fw_mgmt_if_id" {
  value = "${aws_network_interface.fw_mgmt.id}"
}

output "fw_eth2_eip" {
  value = "${aws_eip.fw_eth2_eip.public_ip}"
}

output "fw_eth2_id" {
  value = "${aws_network_interface.fw_eth2.id}"
}
