provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu-18_04" {
  most_recent = true
  owners = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_security_group" "cstrike_security_group" {
  name        = "cstrike_security_group"
  description = "Allow traffic required for counter strike"

  # Allow SSH from anywhere
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp ports first set"
    from_port   = 27000
    to_port     = 27030
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp ports second set"
    from_port   = 4380
    to_port     = 4380
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all output"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Counter Strike Security Group"
  }
}

resource "aws_instance" "cstrike" {
  ami                         = data.aws_ami.ubuntu-18_04.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  monitoring                  = false
  security_groups             = [aws_security_group.cstrike_security_group.name]

  root_block_device {
    volume_size           = 50
    volume_type           = "standard"
    delete_on_termination = true
  }
}
