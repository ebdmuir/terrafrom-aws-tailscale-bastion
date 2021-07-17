resource "aws_instance" "instance" {
  depends_on                  = [aws_s3_bucket_object.object]
  ami                         = var.ami_id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.secgroup_id]
  tags = {
    Name   = "${var.id}_tailscale_bastion"
    Source = var.archive.output_md5
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