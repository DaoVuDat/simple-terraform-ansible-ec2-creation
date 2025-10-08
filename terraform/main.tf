terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Create key-pair for SSH
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key-pair"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Store the key-pair in a file
resource "local_file" "ec2_key_pair" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/runner.pem"
  file_permission = "0400"
}

# Create EC2 Instances
resource "aws_instance" "ec2_instance" {
  for_each = {for ins in var.instances : ins.name => ins}

  ami = "ami-052064a798f08f0d3"
  instance_type = each.value.type
  key_name = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.allow_anywhere.id]
  tags = {
    Name = each.value.name
  }
}

