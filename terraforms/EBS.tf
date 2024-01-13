resource "aws_ebs_volume" "zookeeper_ebs" {
  count = 3  # Adjust the count based on the number of Zookeeper instances

  availability_zone = aws_instance.kafka_zookeeper[count.index].availability_zone
  size              = 40
  type       = "gp2"  # Adjust the volume type as needed

  tags = {
    Name = "zookeeper-ebs-${count.index + 1}"
  }
}

resource "aws_volume_attachment" "zookeeper_ebs_attachment" {
  count = length(aws_instance.kafka_zookeeper)

  volume_id          = aws_ebs_volume.zookeeper_ebs[count.index].id
  instance_id        = aws_instance.kafka_zookeeper[count.index].id
  device_name        = "/dev/sdf"  # Adjust the device name as needed
}