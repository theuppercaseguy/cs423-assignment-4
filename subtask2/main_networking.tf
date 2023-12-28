terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2" 
}

# Create VPC
resource "aws_vpc" "devops_assignment" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true #use to enable vpc's to connect or communicate with the internet/domains
  enable_dns_hostnames = true # same as above
  tags = {
    Name = "devops-assignment-4"
  }
}

# Created two availability zones
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.devops_assignment.id
  cidr_block              = "10.0.1.0/24"  #my desired cider block
  availability_zone       = "us-west-2a"  # my desired region
  map_public_ip_on_launch = true # provide default/any public ip from aws
  tags = {
    Name = "cs423-devopspublic-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.devops_assignment.id
  cidr_block              = "10.0.2.0/24"  # my desired CIDR block
  availability_zone       = "us-west-2a"  # my with your desired AZ
  map_public_ip_on_launch = false #private subnet, no internet access
  tags = {
    Name = "cs423-devops-private-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.devops_assignment.id
  cidr_block              = "10.0.3.0/24" 
  availability_zone       = "us-west-2b"  
  map_public_ip_on_launch = true 
  tags = {
    Name = "cs423-devopspublic-2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.devops_assignment.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-west-2b" 
  map_public_ip_on_launch = false
  tags = {
    Name = "cs423-devops-private-2"
  }
}

# Creating a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.devops_assignment.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }
  tags = {
    Name = "${aws_vpc.devops_assignment.tags.Name}-private-route-table"
  }
}

# Associating private subnets with the private route table 
#for 1st private subnet for internet access internally
resource "aws_route_table_association" "private_subnet_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# for 2nd private subnet for internet access internally
resource "aws_route_table_association" "private_subnet_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create an internet gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_assignment.id
  tags = {
    Name = "devops-assignment-igw"
  }
}

#to access vpc id in other terraforms script
output "vpc_id" {
  value = aws_vpc.devops_assignment.id
}