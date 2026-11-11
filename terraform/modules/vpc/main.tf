// create vpc 
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_vpc
  tags = {
    Name = var.vpc_name
  }
}

// create one public subnet 
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  tags = {
    Name = var.name_public
  }

}

//create numbers of private subnets depends on numbers of cidr (3)
resource "aws_subnet" "private" {
  count          = length(var.cidr_private)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_private[count.index]
  availability_zone       = data.aws_availability_zones.available_az.names[count.index]
  tags = {
    Name = var.name_private[count.index]
  }
}

// create internet gateway andd relatd to vpc
resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = var.igw
  }
}


// create public route table and  assign into internet gateway
resource "aws_route_table" "public_route" {
 vpc_id     = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route"
  }
}

// Assign public route table into public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route.id
}


# // generte nat gateway
resource "aws_nat_gateway" "example" {
  vpc_id = aws_vpc.main.id
  availability_mode = "regional"
  tags = {
    Name = "main-nat"
  }
}

# // create private route table and related to nat gateway
resource "aws_route_table" "private_route" {
  vpc_id     = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.example.id
  }

  tags = {
    Name = "private_route"
  }
}

// Assign private route table into private subnet
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route.id
}