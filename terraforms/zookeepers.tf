# create a security group for kafka zookeepers 


# data "aws_security_group" "kafka_broker_sg" {
#   name = "kafka-broker-sg"
# }


# When you define a security group rule allowing traffic on port 9092 in your aws_security_group resource, 
#it permits incoming traffic on that port from other instances associated with the same security group within the VPC.
# so, our three instances are associated with the same security group, so they can communicate with each other on port 9092, to setup for kafka later


resource "aws_instance" "kafka_zookeeper" {
  count = 3  # Number of instances you want to create

  ami           = "ami-0c7217cdde317cfec"  # Replace with the AMI ID for your desired OS
  instance_type = "t2.medium"     # Choose an appropriate instance type # 8GB RAM and 2 vCPUs 

  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  key_name = aws_key_pair.brokers_key_pair.key_name  # Use the key name from the created key pair - the same as the broker one 

  # Security group configuration (modify as needed)
  vpc_security_group_ids = [aws_security_group.kafka_zookeeper_sg.id]
  # Specify the mount point and perform the mounting

  tags = {
    Name = "kafka-zookeeper-${count.index + 1}"
  }

}


output "kafka_zookeeper_ips" {
  value = [for instance in aws_instance.kafka_zookeeper : instance.private_ip]
}


