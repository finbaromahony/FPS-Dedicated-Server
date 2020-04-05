provider "aws" {
  region                  = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

data "aws_ami" "awslinux_ami" {
  most_recent = true
  name_regex  = "^Amazon Linux 2 AMI.*"
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

module "cstrike_instance" {
  source        = "./modules/cstrike_instance"
  region        = "${var.region}"
  ami_id        = "${data.awslinux_ami.ami_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
}