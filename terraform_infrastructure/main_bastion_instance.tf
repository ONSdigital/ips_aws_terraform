resource "aws_security_group" "bastion_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "${local.common_name_prefix}_bastion-security-group"
  description = "Security Group for the bastion Instance for ${local.common_name_prefix}"

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.bastion_ingress_cidr]
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
  key_name                    = var.deploy_key_name
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
}

