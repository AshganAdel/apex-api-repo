variable "cidr_vpc" {
  type = string
  description = "put the ip address for the vpc"
}


variable "vpc_name" {
  type = string
  description = "put the name for the vpc"
}



variable "name_public" {
  description = "put the name of public subnet"
}


variable "public_subnet_cidr" {
  description = "put the cidr of public subnet"
}


variable "name_private" {
  description = "put the name of 2 private subnets"
}

variable "cidr_private" {
  description = "put the cidr of 2 private subnets"

}

variable "igw" {
  description = "put the name of internet gateway"
  type        = string
}


