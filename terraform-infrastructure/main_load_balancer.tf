resource "aws_security_group" "ips_lb_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "The security group associated with the application load balancer."
  tags = merge(
    local.module_common_tags,
    {
      "Name" = "${local.common_name_prefix}_lb-SG"
    },
  )
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_80" {
  from_port   = 80
  protocol    = "tcp"
  to_port     = 80
  type        = "ingress"
  cidr_blocks = [var.cidr_block_all]

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_gov_wifi" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["80.5.92.42/32"]
  description = "Allow traffic from GovWifi"

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_ons_guest" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["51.7.82.137/32"]
  description = "Allow traffic from ONS Guest"

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_ons_vpn1" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["194.34.204.37/32"]
  description = "Allow traffic from ONS VPN"

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_ons_vpn2" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["194.34.204.36/32"]
  description = "Allow traffic from ONS VPN"

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_ons_vpn3" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["194.34.206.36/32"]
  description = "Allow traffic from ONS VPN"

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_ingress_ons_vpn4" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["194.34.206.37/32"]
  description = "Allow traffic from ONS VPN"

  // rules associated with the security group:
  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_security_group_rule" "ips_lb_sg_egress_all" {
  type        = "egress"
  from_port   = 0
  protocol    = -1
  to_port     = 0
  cidr_blocks = [var.cidr_block_all]

  security_group_id = aws_security_group.ips_lb_sg.id
}

resource "aws_lb" "ips_lb" {
  name               = "${local.common_name_prefix}-ips-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ips_lb_sg.id]
  subnets            = aws_subnet.public_subnets.*.id
  idle_timeout       = 300
}

resource "aws_lb_target_group" "ips_tg" {
  name                 = "${local.common_name_prefix}-Target-Group"
  port                 = "5000"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main_vpc.id
  deregistration_delay = 10

  health_check {
    protocol            = "HTTP"
    port                = 5000
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 6
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "ips_lb_listener" {
  load_balancer_arn = aws_lb.ips_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ips-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ips_tg.arn
  }
}

