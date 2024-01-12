# create a vpc for the kafka cluster
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "kafka-self-managed-vpc"
 }
}

# create three public subnets for the kafka cluster each with dfiferent cidr block and AZ
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs) # number of public subnets to be created 
 vpc_id     = aws_vpc.main.id # main vpc id 
 cidr_block = element(var.public_subnet_cidrs, count.index) # cidr block for each subnet
 availability_zone = element(var.azs, count.index) # availability zone for each subnet
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

# create private subnets for the kafka cluster each with dfiferent cidr block and AZ
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index) # availability zone for each subnet
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

# create a gateway to connect to the internet and attach it to the kafka-self-managed-vpc vpc
# it will be attached to the public subnets created above
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "KAFKA-Project VPC IG"
 }
}

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
