resource "aws_subnet" "public_subnets" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.main_address_space, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.public_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Public-Subnet-${count.index}"
    },
  )
}

resource "aws_route_table" "route_tbl_public" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    local.public_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Public-RTB"
    },
  )
}

resource "aws_route" "public_subnet_route" {
  route_table_id         = aws_route_table.route_tbl_public.id
  destination_cidr_block = var.cidr_block_all
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "route_tbl_assoc_public" {
  count          = length(aws_subnet.public_subnets)
  route_table_id = aws_route_table.route_tbl_public.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}

resource "aws_security_group" "public_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with all the pubilc subnets"
  tags = merge(
    local.public_vpc_resource_tags,
    {
      "Name" = "${local.common_name_prefix}_Public-SG"
    },
  )
}

