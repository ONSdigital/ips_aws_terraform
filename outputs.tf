output "subnet_ids" {
  value = [
    "${aws_subnet.public_subnets.*.id}",
    "${aws_subnet.private_subnets.*.id}",
  ]
}

output "private_subnet_ids" {
  value = [
    "${aws_subnet.private_subnets.*.id}",
  ]
}

output "public_subnet_ids" {
  value = [
    "${aws_subnet.public_subnets.*.id}",
  ]
}

output "vpc_id" {
  value       = "${aws_vpc.main_vpc.id}"
  description = "The VPC id created"
}

output "aws_internet_gateway" {
  value = "${aws_internet_gateway.igw.id}"
}

output "aws_route_table_public" {
  value = [
    "${aws_route_table.route_tbl_public.*.id}",
  ]
}

output "aws_route_table_private" {
  value = [
    "${aws_route_table.route_tbl_private.*.id}",
  ]
}

output "aws_route_table_associaton_public" {
  value = "${aws_route_table_association.route_tbl_assoc_public.*.id}"
}

output "aws_route_table_associaton_private" {
  value = "${aws_route_table_association.route_tbl_assoc_private.*.id}"
}

output "nat_instance_id" {
  value = "${aws_instance.nat.id}"
}

output "nat_private_ip" {
  value = "${aws_instance.nat.private_ip}"
}

output "nat_public_ip" {
  value = "${aws_instance.nat.public_ip}"
}

output "nat_public_dns" {
  value = "${aws_instance.nat.public_dns}"
}

output "nat_sg_id" {
  value = "${aws_security_group.natsg.id}"
}
