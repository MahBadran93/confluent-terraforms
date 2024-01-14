# EC2 Instance in Public Subnet
resource "aws_instance" "nat_host" {
  ami           = "ami-0c7217cdde317cfec"  # Replace with your AMI ID
  instance_type = "t2.medium"
  subnet_id     = element(aws_subnet.public_subnets[*].id, 0) # create it in the first public subnet 
  associate_public_ip_address = true  
  vpc_security_group_ids  = [aws_security_group.nat_sg.id]
  # Other instance configurations...

  tags = {
    Name = "nat_host"
  }
}