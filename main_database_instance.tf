locals {
  db_name_from_arg = local.common_name_prefix

  # RDS DB Identifier only allows Alpha numeric and hyphens
  sanitize_for_db_identifier       = replace(local.db_name_from_arg, "/[^[0-9A-Za-z\\-]]/", "-")
  truncate_length_of_db_identifier = substr(local.sanitize_for_db_identifier, 0, 63)
  db_identifier                    = local.truncate_length_of_db_identifier

  # RDS DB Name only allows Alpha numeric and underscores
  sanitize_for_db_name       = replace(local.db_name_from_arg, "/\\W/", "_") #  Replace \W ( matches anything except [0-9A-Za-z_]) with a underscore
  truncate_length_of_db_name = substr(local.sanitize_for_db_name, 0, 63)
  db_name                    = local.truncate_length_of_db_name
}

resource "aws_db_subnet_group" "db-subnet" {
  name       = "ips-db-subnet"
  subnet_ids = aws_subnet.private_subnets.*.id

  tags = {
    Name = "ips-db-subnet",
    app  = "ips-db"
  }
}

resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    local.private_vpc_resource_tags,
    {
      "Name"      = "${local.common_name_prefix}-db-sg"
      "FilterKey" = "${local.common_name_prefix}-DB-Security-Group"
    },
  )
}

resource "aws_security_group_rule" "db_sg_self" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  self      = true

  // rules associated with security group:
  security_group_id = aws_security_group.db-sg.id
}

resource "aws_security_group_rule" "db_sg_from_bastion" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "ingress"
  // traffic from:
  source_security_group_id = aws_security_group.bastion_sg.id

  // rules associated with security group:
  security_group_id = aws_security_group.db-sg.id
}

resource "aws_security_group_rule" "db_sg_egress_all" {
  from_port = 0
  protocol  = -1
  to_port   = 0
  type      = "egress"
  cidr_blocks = [var.cidr_block_all]

  // rules associated with security group:
  security_group_id = aws_security_group.db-sg.id
}

resource "aws_db_instance" "default" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = var.instance_class

  name       = var.db_name
  identifier = local.db_identifier

  username = var.db_user_name
  password = var.db_password

  parameter_group_name = "${aws_db_parameter_group.database.name}"

  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name

  skip_final_snapshot = true

  tags = merge(
    local.module_common_tags,
    {
      "Name" = local.common_name_prefix
    },
  )
}

resource "aws_db_parameter_group" "database" {
  name   = var.parameter_group_name
  family = "mysql5.7"

  parameter {
    name  = "wait_timeout"
    value = "31536000"
  }

//  parameter {
//    name  = "innodb_log_file_size"
//    value = ""
//  }

  parameter {
    name  = "max_allowed_packet"
    value = "1073741824"
  }

}