terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_ec2_managed_prefix_list" "instance_connect" {
  name = "com.amazonaws.us-east-1.ec2-instance-connect"
}


resource "aws_security_group" "jenkins" {
  name_prefix = "${var.project_name}-"
  description = "Acceso web a Jenkins"

  # Jenkins Web - Puerto 8080
  ingress {
    description = "Jenkins Web"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # SSH - EC2 Instance Connect
  ingress {
    description     = "SSH desde EC2 Instance Connect"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.instance_connect.id]
  }

  # Permitir conexiones de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}


resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  # Instalacion automatica de Jenkins
  user_data = file("${path.module}/install-jenkins.sh")

  # Disco principal
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = var.project_name
  }
}
