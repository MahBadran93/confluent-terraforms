# create a route table for the public subnets to connect to the internet via the internet gateway created above
resource "aws_route_table" "second_rt_for_public_subnets" {
 vpc_id = aws_vpc.main.id
 # create a route that will recieve all traffic from the internet (0.0.0.0/0) and connect to the internet gateway created above
 # this route will be attached to the public subnets in our kafka vpc so we can have intenet access to these public subnets
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "2nd Route Table for Public Subnets"
 }
}

# associate the public subnets with the route table created above
resource "aws_route_table_association" "public_subnet_association" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt_for_public_subnets.id
}




# Create a route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}
# associate private subnets with a route table 
resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}


