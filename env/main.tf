data "aws_region" "current" {}

resource "aws_vpc" "app_infrastructure_vpc" {
  cidr_block           = "10.0.1.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "APP VPC"
  }
}

resource "aws_internet_gateway" "app_infrastructure_gateway" {
  vpc_id = aws_vpc.app_infrastructure_vpc.id

  tags = {
    Name = "APP IGW"
  }
}

resource "aws_subnet" "app_infrastructure_subnet" {
  vpc_id            = aws_internet_gateway.app_infrastructure_gateway.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "APP Public Subnet"
  }
}

resource "aws_route_table" "app_infrastructure_route_table" {
  vpc_id = aws_vpc.app_infrastructure_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_infrastructure_gateway.id
  }

  tags = {
    Name = "APP Pulib Route Table"
  }
}

resource "aws_route_table_association" "app_infrastructure_route_table_association" {
  subnet_id      = aws_subnet.app_infrastructure_subnet.id
  route_table_id = aws_route_table.app_infrastructure_route_table.id
}

resource "aws_instance" "ec2" {
  count                       = var.instance_count
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = "EC2KeyPair"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.app_infrastructure_subnet.id
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.web.id
  ]

  tags = {
    Name = element(var.instance_tags, count.index)
  }
}