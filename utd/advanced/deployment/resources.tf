resource "aws_key_pair" "ssh_key" {
  key_name   = "utd_aws" # clef SSH d'authentification pour AWS
  public_key = "${file(var.public_key_file)}"
}
# Define SSH key pair for our instances