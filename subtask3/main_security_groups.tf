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

# Fetching VPC ID from local state
data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../subtask2/terraform.tfstate"  #Must adjust the path to your VPC Terraform state file
  }
}

# Creating a security group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-sg"
  description = "Security group for EC2 instances"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id  # Referencing the VPC created in Task 2 locally

  #ingress == incoming traffic
  # Inbound rules for ssh
  ingress {
    from_port   = 22  # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allowing SSH from anywhere
  }

# inboud rules for https traffic
  ingress {
    from_port   = 80  # HTTP for web server
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }
  
  #egress == outwards traffic
  # Outbound rules (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}







