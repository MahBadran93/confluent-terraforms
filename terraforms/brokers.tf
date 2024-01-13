# create a security group for kafka brokers 

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

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    security_groups = [aws_security_group.kafka_zookeeper_sg.id] # allow incoming traffic to kafka brokers nodes on port 2181 from the security group of zookeeper nodeds for tasks like leader election 
  }

  ingress {
    from_port   = 22  # SSH port
    to_port     = 22
    protocol    = "tcp"
    # Add the source IP or security group that should be allowed to connect via SSH
    # For example, if your bastion host is in a security group, you can reference it:
    security_groups = [aws_security_group.bastion_sg.id]
  }

}

resource "aws_instance" "kafka_broker" {
  count = 3  # Number of instances you want to create

  ami           = "ami-0005e0cfe09cc9050"  # Replace with the AMI ID for your desired OS
  instance_type = "t2.large"     # Choose an appropriate instance type # 8GB RAM and 2 vCPUs 

  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  key_name = aws_key_pair.brokers_key_pair.key_name  # Use the key name from the created key pair

  # Security group configuration (modify as needed)
  vpc_security_group_ids = [aws_security_group.kafka_broker_sg.id]

#   key_name = "your_key_pair_name"  # Replace with your key pair name

#   # User data script to install Kafka or other configurations (modify as needed)
#   user_data = <<-EOF
#               #!/bin/bash
#               # Your user data script here
#               EOF

  tags = {
    Name = "kafka-broker-${count.index + 1}"
  }
}


output "kafka_broker_ips" {
  value = [for instance in aws_instance.kafka_broker : instance.private_ip]
}