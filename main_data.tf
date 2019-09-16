data "aws_ami" "nat_instance_ami" {
  most_recent = true
  owners      = ["137112412989"]
  name_regex  = ".*amzn-ami-vpc-nat-2018.*"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
}

data "aws_security_group" "allow_ingress_into_db_sg" {
  vpc_id = "${var.db_vpc_id}"

  filter {
    name   = "tag:Name"
    values = ["ips-db-prod-sg"]
  }
}

resource "aws_security_group_rule" "ingress-into-db-group-sg-rule" {
  type              = "ingress"
  description       = "Allows TCP 5432 from web_sg into db_sg"
  security_group_id = "${data.aws_security_group.allow_ingress_into_db_sg.id}"

  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.ips_servs_sg.id}"
}