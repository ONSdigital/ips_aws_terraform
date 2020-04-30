//# Lookup requestor route tables
variable "enabled" {
  default = "true"
}

data "aws_vpc" "acceptor" {
  // "Result depends on values that cannot be determined until after the "terraform apply"...apply had been run...
  filter {
    name   = "tag:Name"
    values = [var.peered_vpc_name]
  }
}

resource "aws_vpc_peering_connection" "default" {
  vpc_id      = aws_vpc.main_vpc.id
  peer_vpc_id = join("", data.aws_vpc.acceptor.*.id)
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = local.module_common_tags
}


# Lookup acceptor subnets
data "aws_subnet_ids" "acceptor" {
  vpc_id = data.aws_vpc.acceptor.id
}

# Lookup acceptor route tables
data "aws_route_table" "acceptor" {
  count     = var.enabled == "true" ? length(distinct(sort(data.aws_subnet_ids.acceptor.ids))) : 0
  subnet_id = distinct(sort(data.aws_subnet_ids.acceptor.ids))[count.index]
}

//# Create routes from requestor to acceptor
resource "aws_route" "requestor_public" {
  route_table_id            = aws_route_table.route_tbl_public.id
  destination_cidr_block    = data.aws_vpc.acceptor.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
  depends_on                = [aws_vpc_peering_connection.default]
}

resource "aws_route" "requestor_private" {
  route_table_id            = aws_route_table.route_tbl_private.id
  destination_cidr_block    = data.aws_vpc.acceptor.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
  depends_on                = [aws_vpc_peering_connection.default]
}

# Create routes from acceptor to requestor
resource "aws_route" "acceptor" {
  count                     = var.enabled == "true" ? length(distinct(sort(data.aws_route_table.acceptor.*.route_table_id))) : 0
  route_table_id            = distinct(sort(data.aws_route_table.acceptor.*.route_table_id))[count.index]
  destination_cidr_block    = var.main_address_space
  vpc_peering_connection_id = aws_vpc_peering_connection.default.id
  depends_on                = [data.aws_route_table.acceptor, aws_vpc_peering_connection.default]
}
