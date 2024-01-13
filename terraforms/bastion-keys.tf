
# provider "aws" {
#   region = element(aws_subnet.public_subnets[*].availability_zone, 0)
# }
resource "tls_private_key" "bastion-private-key" {
  algorithm = "RSA"
}

data "tls_public_key" "bastion-public-key" {
  private_key_pem = tls_private_key.bastion-private-key.private_key_pem
}

resource "aws_key_pair" "key_pair" {
  key_name   = "bastion-key-pair"
  public_key = data.tls_public_key.bastion-public-key.public_key_openssh
}

resource "null_resource" "write_private_key_bastion" {
  depends_on = [aws_key_pair.key_pair]

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p bastion-keys  # Create the folder if it doesn't exist   
      echo '${tls_private_key.bastion-private-key.private_key_pem}' > bastion-keys/bastion-key-pair.pem
    EOT
  }
}
