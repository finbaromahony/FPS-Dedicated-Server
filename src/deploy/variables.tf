variable "image_id" {
    type = string
    description = "The id of the machine image (AMI) to use for the server"
}

variable "region" {
    type = string
    default = "eu-west-1"
}

