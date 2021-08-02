provider "aws" {
  region = "us-east-1"
}

/*
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
*/