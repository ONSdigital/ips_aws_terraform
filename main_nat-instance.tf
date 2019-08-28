resource "aws_security_group" "natsg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "${local.common_name_prefix}_NAT-security-group"
  description = "Security Group for the NAT Instance for ${local.common_name_prefix}"

  ingress {
    from_port   = 53
    protocol    = "udp"
    to_port     = 53
    cidr_blocks = aws_subnet.private_subnets.*.cidr_block
  }

  ingress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    security_groups = [aws_security_group.ui_sg.id]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = [local.bastion_ingress_cidr]
  }

  ingress {
    from_port = 0
    protocol  = -1
    to_port   = 0
    self      = true
  }

  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [var.cidr_block_all]
  }

  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [var.cidr_block_all]
  }

  egress {
    from_port   = 53
    protocol    = "udp"
    to_port     = 53
    cidr_blocks = [var.cidr_block_all]
  }

  egress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
    cidr_blocks = concat(
      aws_subnet.private_subnets.*.cidr_block,
      aws_subnet.public_subnets.*.cidr_block,
    )
  }

  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_NAT-Instance-SG"
    },
  )
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.nat_instance_ami.id
  instance_type               = "t2.micro"
  key_name                    = var.deploy_key_name
  associate_public_ip_address = true
  source_dest_check           = false

  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.natsg.id, aws_security_group.public_sg.id]

  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_NAT-Instance"
    },
  )
}

