# data "aws_security_group" "kafka_zookeeper_sg" {
#   name = "kafka-zookeeper-sg"
# }
# data "aws_security_group" "kafka_broker_sg" {
#   name = "kafka-broker-sg"
# }

resource "aws_security_group" "kafka_zookeeper_sg" {
  name        = "kafka-zookeeper-sg"
  description = "Security group for Kafka zookeeper in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    self        = true # this make it explicit that instances associated with this security group can communicate with each other on port 9092
  }

#    ingress {
#     from_port   = 9092
#     to_port     = 9092
#     protocol    = "tcp"
#     security_groups = [aws_security_group.kafka_broker_sg.id] 
#   }

  ingress {
    from_port   = 22  # SSH port
    to_port     = 22
    protocol    = "tcp"
    # Add the source IP or security group that should be allowed to connect via SSH
    # For example, if your bastion host is in a security group, you can reference it:
    security_groups = [aws_security_group.bastion_sg.id]
  }

   # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



# When you define a security group rule allowing traffic on port 9092 in your aws_security_group resource, 
#it permits incoming traffic on that port from other instances associated with the same security group within the VPC.
# so, our three instances are associated with the same security group, so they can communicate with each other on port 9092, to setup for kafka later

resource "aws_security_group" "kafka_broker_sg" {
  name        = "kafka-broker-sg"
  description = "Security group for Kafka brokers in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    self        = true # this make it explicit that instances associated with this security group can communicate with each other on port 9092
  }

#   ingress {
#     from_port   = 2181
#     to_port     = 2181
#     protocol    = "tcp"
#     security_groups = [aws_security_group.kafka_zookeeper_sg.id] 
#   }

  ingress {
    from_port   = 22  # SSH port
    to_port     = 22
    protocol    = "tcp"
    # Add the source IP or security group that should be allowed to connect via SSH
    # For example, if your bastion host is in a security group, you can reference it:
    security_groups = [aws_security_group.bastion_sg.id]
  }

   # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



# create rules 
# allow incoming traffic to kafka brokers nodes on port 2181 from the security group of zookeeper nodeds for tasks like leader election 
resource "aws_security_group_rule" "allow_incoming_traffic_to_brokers" {
    type = "ingress"
    from_port = 2181
    to_port = 2181
    protocol = "tcp"
    security_group_id = aws_security_group.kafka_broker_sg.id
    source_security_group_id = aws_security_group.kafka_zookeeper_sg.id
}

# allow incoming traffic to zookeeper nodes on port 9092 from the security group of kafka brokers for tasks like leader election 
resource "aws_security_group_rule" "allow_incoming_traffic_to_zookeepers" {
    type = "ingress"
    from_port = 9092
    to_port = 9092
    protocol = "tcp"
    security_group_id = aws_security_group.kafka_zookeeper_sg.id
    source_security_group_id = aws_security_group.kafka_broker_sg.id
}
# # Allow outgoing traffic from zookeeper nodes to Kafka brokers on port 9092
# resource "aws_security_group_rule" "allow_outgoing_traffic_to_kafka" {
#   type                     = "egress"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"

#   cidr_blocks = ["0.0.0.0/0"]
# }

 



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
    cidr_blocks = ["212.33.113.168/32"] # Allow SSH only from my IP - mahmoud local machine dynamic ip needs to be changed just for testing
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



# create NAT security group
# Security Group for NAT Gateway
resource "aws_security_group" "nat_sg" {
  name        = "nat-security-group"
  description = "Security group for the NAT gateway"
  vpc_id      = aws_vpc.main.id

  # Outbound rule for allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}