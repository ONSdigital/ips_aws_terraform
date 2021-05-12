variable "main_address_space" {
  default = "10.30.0.0/16"
}

variable "public_subnet_count" {
  default = 2
}

variable "private_subnet_count" {
  default = 2
}

variable "cidr_block_all" {
  default = "0.0.0.0/0"
}

# Mandataory inputs
variable "deploy_key_name" {}

variable "common_name" {}

variable "db_name" {}

variable "db_user_name" {}

variable "db_password" {}

variable "ecr_repo" {
}

variable "dns_zone_name" {
}

variable "ui_docker_image_tag_name" {
  default = "latest"
}

variable "services_docker_image_tag_name" {
  default = "latest"
}

variable instance_class {
  type    = string
  default = "db.t3.medium"
}

variable parameter_group_name {
  type    = string
  default = "ips-mysql"
}

variable "role_arn" {}
