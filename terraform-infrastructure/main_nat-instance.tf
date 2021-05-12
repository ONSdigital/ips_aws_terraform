resource "aws_security_group" "natsg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "${local.common_name_prefix}_NAT-Security-Group"
  description = "Security Group for the NAT Instance for ${local.common_name_prefix}"

  ingress {
    from_port   = 53
    protocol    = "udp"
    to_port     = 53
    cidr_blocks = aws_subnet.private_subnets.*.cidr_block
    description = "Allow UDP:53"
  }

  ingress {
    from_port       = 0
    protocol        = "tcp"
    to_port         = 65535
    security_groups = [aws_security_group.ui_sg.id]
    description     = "All TCP ingress from UI SG"
  }

  ingress {
    from_port       = 0
    protocol        = "tcp"
    to_port         = 65535
    security_groups = [aws_security_group.ips_servs_sg.id]
    description     = "All TCP ingress from services SG"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["194.34.204.36/32", "194.34.206.36/32", "194.34.206.37/32"]
    description = "SSH ingress from specific ip"
  }

  ingress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    self        = true
    description = "Allow all traffic within self"
  }

  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [var.cidr_block_all]
    description = "Allow all HTTP traffic"
  }

  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [var.cidr_block_all]
    description = "Allow all HTTPS traffic"
  }

  egress {
    from_port   = 53
    protocol    = "udp"
    to_port     = 53
    cidr_blocks = [var.cidr_block_all]
    description = "Allow all DNS traffic"
  }

  egress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
    cidr_blocks = concat(
      aws_subnet.private_subnets.*.cidr_block,
      aws_subnet.public_subnets.*.cidr_block,
    )
    description = "Allow outgoing MySQL Traffic"
  }

  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_NAT-Instance-SG"
    },
  )
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.al2_ami.id
  instance_type               = "t2.micro"
  key_name                    = var.deploy_key_name
  associate_public_ip_address = true
  source_dest_check           = false

  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.natsg.id, aws_security_group.public_sg.id]

  user_data = <<EOF
#!/bin/bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo systemctl stop rpcbind
  EOF

  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_NAT-Instance"
    },
  )
}


data "aws_ami" "al2_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
