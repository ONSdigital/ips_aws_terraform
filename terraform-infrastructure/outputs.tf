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

output "sql_host" {
  value = aws_db_instance.default.address
}

output "sql_password" {
  value     = aws_db_instance.default.password
  sensitive = true
}

output "bastion_id" {
  value = aws_instance.bastion.id
}

output "ecr_repo" {
  value = var.ecr_repo
}

output "bastion_ssh_public_key" {
  value = tls_private_key.bastion.public_key_openssh
}

output "bastion_ssh_private_key" {
  value     = tls_private_key.bastion.private_key_pem
  sensitive = true
}

output "nat_ssh_public_key" {
  value = tls_private_key.nat.public_key_openssh
}

output "nat_ssh_private_key" {
  value     = tls_private_key.nat.private_key_pem
  sensitive = true
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ips_cluster.name
}

output "task_definition_ui" {
  value = aws_ecs_task_definition.ui_task_def.arn
}

output "task_definition_services" {
  value = aws_ecs_task_definition.ips_servs_task_def.arn
}