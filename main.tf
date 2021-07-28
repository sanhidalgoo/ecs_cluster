provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    "Name" = "main VPC"
  }
}

output "aws_vpc_id" {
  value = "${aws_vpc.main-vpc.id}"
}

# Create the first public subnet
resource "aws_subnet" "pub-subnet-1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "172.16.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "pub-subnet-1"
  }
}

# Create the second public subnet
resource "aws_subnet" "pub-subnet-2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "172.16.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-2"
  }
}

# Internet Gateway for main-vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    "Name" = "igw"
  }
}

# Create Custom Route Table
resource "aws_route_table" "internet-rtable" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "internet-rtable"
  }
}

# Associate public subnets with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub-subnet-1.id
  route_table_id = aws_route_table.internet-rtable.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pub-subnet-2.id
  route_table_id = aws_route_table.internet-rtable.id
}

#Route the public subnets traffic through the IGW
resource "aws_route" "internet-access" {
  route_table_id = aws_route_table.internet-rtable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}


# Securuty Group: Allow ssh inbound traffic
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "H1" {
  ami = "ami-0c2b8ca1dad447f8a"
  key_name = "ecs_cluster"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub-subnet-1.id
  security_groups = [aws_security_group.allow_ssh.id]
  
  tags = {
    "Name" = "H1"
  }
}