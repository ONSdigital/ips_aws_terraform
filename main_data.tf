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

data "aws_ami" "nat_instance_ami_bastion" {
  most_recent = true
  owners      = ["137112412989"]
  name_regex  = "amzn2-ami-hvm-2.0.20190618-x86_64-gp2"

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

