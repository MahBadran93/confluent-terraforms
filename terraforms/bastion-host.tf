# Bastion Host Security Group
# add a security group for the bastion host to allow SSH from my IP only
# the bastion host will be used to connect to the private instances in the private subnet to be able to setup kafka via ansible 
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["139.190.184.234/32"] # Allow SSH only from my IP - mahmoud local machine 
  }
  # allow outbound traffic to the private subnets
  dynamic egress {
    for_each = aws_subnet.private_subnets
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [egress.value.cidr_block]
    }
  }


  # Add any other necessary rules...
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion_host" {
  ami           = "ami-0005e0cfe09cc9050"  # Replace with the AMI ID for your desired OS
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



