locals {
}

resource "aws_subnet" "private_subnets" {
  count = var.private_subnet_count

  vpc_id = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(
    var.main_address_space,
    8,
    count.index + length(aws_subnet.public_subnets),
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.private_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Private-Subnet-${count.index}"
    },
  )
}

resource "aws_route_table" "route_tbl_private" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    local.private_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Private-RTB"
    },
  )
}

resource "aws_route" "private_subnet_route" {
  route_table_id         = aws_route_table.route_tbl_private.id
  destination_cidr_block = var.cidr_block_all
  instance_id            = aws_instance.nat.id
}

resource "aws_route_table_association" "route_tbl_assoc_private" {
  count          = length(aws_subnet.private_subnets)
  route_table_id = aws_route_table.route_tbl_private.id
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)} "
}

resource "aws_security_group" "private_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with all the pubilc subnets"
  tags = merge(
    local.private_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Private-SG"
    },
  )
}

