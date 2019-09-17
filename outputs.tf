output "subnet_ids" {
  value = [
    aws_subnet.public_subnets.*.id,
    aws_subnet.private_subnets.*.id,
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnets.*.id,
  ]
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnets.*.id,
  ]
}

output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "The VPC id created"
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.igw.id
}

output "aws_route_table_public" {
  value = [
    aws_route_table.route_tbl_public.*.id,
  ]
}

output "aws_route_table_private" {
  value = [
    aws_route_table.route_tbl_private.*.id,
  ]
}

output "aws_route_table_associaton_public" {
  value = aws_route_table_association.route_tbl_assoc_public.*.id
}

output "aws_route_table_associaton_private" {
  value = aws_route_table_association.route_tbl_assoc_private.*.id
}

output "nat_instance_id" {
  value = aws_instance.nat.id
}

output "nat_private_ip" {
  value = aws_instance.nat.private_ip
}

output "nat_public_ip" {
  value = aws_instance.nat.public_ip
}

output "nat_public_dns" {
  value = aws_instance.nat.public_dns
}

output "nat_sg_id" {
  value = aws_security_group.natsg.id
}

output "lb_public_dns" {
  description = "Pubilc DNS of the main load balancer"
  value       = "http://${aws_lb.ips_lb.dns_name}"
}

output "DB_Peering_Connection" {
  value = "Setting up peering connection from ${aws_vpc.main_vpc.tags["Name"]} to ${data.aws_vpc.acceptor.tags["Name"]}"
}
