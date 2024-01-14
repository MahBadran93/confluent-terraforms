
# create a gateway to connect to the internet and attach it to the kafka-self-managed-vpc vpc
# it will be attached to the public subnets created above
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "KAFKA-Project VPC IG"
 }
}


# create a NAT gateway 
# this NAT gate way will be connected to the first public subnet 
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_eip2.id 
  subnet_id     = element(aws_subnet.public_subnets[*].id, 0)
  tags = {
    Name = "my-nat-gateway"
  }
}