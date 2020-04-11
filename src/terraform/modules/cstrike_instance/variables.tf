variable "region" {}
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}

locals {
  tags = {
    name          = "counter-strike-server"
    version       = "1.6"
    instance_type = "${var.instance_type}"
  }
}