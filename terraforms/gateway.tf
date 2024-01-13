
# create a gateway to connect to the internet and attach it to the kafka-self-managed-vpc vpc
# it will be attached to the public subnets created above
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "KAFKA-Project VPC IG"
 }
}