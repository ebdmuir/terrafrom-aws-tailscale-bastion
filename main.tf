provider "aws" {
  profile = "work"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

output "vpc" {
  value = data.aws_vpc.selected
}

resource "aws_security_group" "egress_only" {
  name        = "${var.vpc_id}_tailscale_bastion"
  description = "Allow Egress traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_id}_tailscale_bastion"
  }
}

resource "aws_instance" "instance" {
  depends_on                  = [aws_s3_bucket_object.object]
  ami                         = var.ami_id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.egress_only.id]
  tags = {
    Name   = "${var.vpc_id}_tailscale_bastion"
  }

  user_data = <<EOF
#!/bin/bash
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.gpg | apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.list | tee /etc/apt/sources.list.d/tailscale.list

apt-get update && apt-get install -y tailscale

systemctl enable --now tailscaled
tailscale up --authkey="${var.ts_key}" --advertise-routes=${var.route_string}
EOF

  lifecycle {
    create_before_destroy = true
  }
}