// ID OF VPC
output "vpc_id"{
  value = aws_vpc.main.id

}
// ID OF PUBLIC SUBNET
output "public_subnet_id" {
  value = aws_subnet.public.id
}

// ID OF PRIVATE SUBNET 
output "private_subnet_id" {
  value = aws_subnet.private[*].id
}

output "azs" {
  value = data.aws_availability_zones.available_az.names
}