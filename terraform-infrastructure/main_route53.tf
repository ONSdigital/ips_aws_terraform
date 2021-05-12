data "aws_route53_zone" "ips-private" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "ips-type-A" {
  zone_id = data.aws_route53_zone.ips-private.zone_id
  name    = data.aws_route53_zone.ips-private.name
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_lb.ips_lb.dns_name
    zone_id                = aws_lb.ips_lb.zone_id
  }

  allow_overwrite = true
}

resource "aws_acm_certificate" "ips-cert" {
  domain_name       = data.aws_route53_zone.ips-private.name
  validation_method = "DNS"
}
resource "aws_route53_record" "ips-cert-validation" {
  name    = aws_acm_certificate.ips-cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.ips-cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.ips-private.id
  records = [aws_acm_certificate.ips-cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "ips-cert" {
  certificate_arn = aws_acm_certificate.ips-cert.arn
  validation_record_fqdns = [
    aws_route53_record.ips-cert-validation.fqdn
  ]
}