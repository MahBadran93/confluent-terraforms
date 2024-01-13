# create a vpc for the kafka cluster
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "kafka-self-managed-vpc"
 }
}




