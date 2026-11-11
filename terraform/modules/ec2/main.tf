resource "aws_instance" "ec2" {
  count = length(var.ec2_names)
  subnet_id = var.subnet_id
  instance_type = var.instance_type[count.index]
  ami = var.ami 
  associate_public_ip_address = var.public_ip_or_not
  vpc_security_group_ids = var.security_group_ids
  key_name = var.key_name
  root_block_device {
    volume_size = var.volume_size
  }
  tags = {
    Name = var.ec2_names[count.index]
  }
}
