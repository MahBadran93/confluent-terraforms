# create a security group for kafka brokers 

# Define a data source to get the security group IDs
# data "aws_security_group" "kafka_zookeeper_sg" {
#   name = "kafka-zookeeper-sg"
# }





resource "aws_instance" "kafka_broker" {
  count = 3  # Number of instances you want to create

  ami           = "ami-0c7217cdde317cfec"  # Replace with the AMI ID for your desired OS
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