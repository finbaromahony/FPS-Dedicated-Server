resource "aws_instance" "cstrike" {
  tags                        = "${local.instance_tags}"
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  monitoring                  = false

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    terminate_on_deletion = true
  }
}