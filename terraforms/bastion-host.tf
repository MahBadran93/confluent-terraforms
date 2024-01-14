
# Bastion Host EC2 Instance
resource "aws_instance" "bastion_host" {
  ami           = "ami-0c7217cdde317cfec"  # Replace with the AMI ID for your desired OS
  instance_type = "t2.medium"            # Choose an appropriate instance type

  subnet_id               = element(aws_subnet.public_subnets[*].id, 0)
  key_name                = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids  = [aws_security_group.bastion_sg.id]


  tags = {
    Name = "bastion-host"
  }
}

output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}



