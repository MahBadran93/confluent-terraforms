
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