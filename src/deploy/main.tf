provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

data "aws_ami" "aws_linux_two" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name = "name"
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

resource "aws_instance" "cstrike" {
  ami                         = "${data.aws_ami.aws_linux_two.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  monitoring                  = false

  root_block_device {
    volume_size           = 10
    volume_type           = "standard"
    delete_on_termination = true
  }
}
