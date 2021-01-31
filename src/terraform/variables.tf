variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "fps_dedicated_rsa"
}

variable "ubuntu_account_number" {
  type = string
  default = "099720109477"
}
