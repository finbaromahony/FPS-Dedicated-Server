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

resource "aws_security_group" "fps_security_group" {
  name        = "fps_security_group"
  description = "Allow traffic required for counter strike and pavlov"

  # Allow SSH from anywhere
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp ports first set CS"
    from_port   = 27000
    to_port     = 27030
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp ports second set CS"
    from_port   = 4380
    to_port     = 4380
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow incoming pings"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp ports 1st set pavlov"
    from_port   = 7777
    to_port     = 7777
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp ports 2st set pavlov"
    from_port   = 8177
    to_port     = 8177
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Allow tcp ports 1st set pavlov"
    from_port   = 7777
    to_port     = 7777
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow tcp ports 2st set pavlov"
    from_port   = 8177
    to_port     = 8177
    protocol    = "tcp"
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
    Name = "fps Security Group"
  }
}

resource "aws_instance" "fps" {
  ami                         = data.aws_ami.ubuntu-18_04.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  monitoring                  = false
  security_groups             = [aws_security_group.fps_security_group.name]

  root_block_device {
    volume_size           = 50
    volume_type           = "standard"
    delete_on_termination = true
  }
}
