variable "azs" {
  type = "list"
  default = ["us-east-1a","us-east-1b","us-east-1c"]
}

# VPC
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "HelloWorld"
  }
}

# Subnets : public
resource "aws_subnet" "subnet1" {
  cidr_block = "10.0.8.0/24"
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-subnet1"
  }
}

# Subnets : private1
resource "aws_subnet" "subnet2" {
  cidr_block = "10.0.4.0/24"
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "terraform-subnet2"
  }
}

# Subnets : private2
resource "aws_subnet" "subnet3" {
  cidr_block = "10.0.6.0/24"
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "us-east-1c"
  tags = {
    Name = "terraform-subnet3"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terraform-internet-gateway" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "terraform-internet-gateway"
  }
}

resource "aws_route_table_association" "subnet1_route_table_association" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.subnet1.id
}
resource "aws_route_table_association" "subnet2_route_table_association" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.subnet2.id
}
resource "aws_route_table_association" "subnet3_route_table_association" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.subnet3.id
}

# Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-internet-gateway.id
  }
}

