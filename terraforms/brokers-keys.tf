
# brokers keys 
resource "tls_private_key" "brokers-private-key" {
  algorithm = "RSA"
}

data "tls_public_key" "brokers-public-key" {
  private_key_pem = tls_private_key.brokers-private-key.private_key_pem
}

resource "aws_key_pair" "brokers_key_pair" {
  key_name   = "brokers-key-pair"
  public_key = data.tls_public_key.brokers-public-key.public_key_openssh
}

resource "null_resource" "write_private_key_brokers1" {
  depends_on = [aws_key_pair.brokers_key_pair]

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p broker-keys  # Create the folder if it doesn't exist  
      echo '${tls_private_key.brokers-private-key.private_key_pem}' > broker-keys/brokers-key-pair.pem
    EOT
  }
}
