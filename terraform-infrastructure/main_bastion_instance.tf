resource "aws_security_group" "bastion_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "${local.common_name_prefix}_bastion-security-group"
  description = "Security Group for the bastion Instance for ${local.common_name_prefix}"

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = [
      "34.89.44.102/32",  # Concourse
      "194.34.204.36/32", # ONS VPN
      "194.34.206.36/32", # ONS VPN
      "194.34.206.37/32", # ONS VPN
    ]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = [var.cidr_block_all]
  }

  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}-bastion-sg-db"
    },
  )
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.nat_instance_ami_bastion.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = true
  source_dest_check           = false

  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}-bastion-intance"
    },
  )

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install mysql"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.bastion.private_key_pem
    }
  }
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}
