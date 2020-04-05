

provider "aws" {
    region = "eu-west-1"
    shared_credentials_file = "~/.aws/credentials"
    profile = "default"
}

data "aws_ami" "example" {
    executable_users = ["self"]
    most_recent = true
    name_regex = ""
    owners = ["self"]

    filter {
        name = "name"
        values = [""]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

}

resource "aws_security_group" "cstrikesg" {
    name = "terraform counter-strike security group"
    ingress{
        description = "Allow SSH access"
        from port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0"]
    }



    tags = {
        Name = "counter-strike security group"

    }
}