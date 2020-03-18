output "web_instance_id1" {
  value = "${aws_instance.web1.id}"
}
output "web_instance_id2" {
  value = "${aws_instance.web2.id}"
}