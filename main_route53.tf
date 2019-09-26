data "aws_route53_zone" "ips-private" {
  name = "ons-ips.uk."
}

resource "aws_route53_record" "ips-type-A" {
  zone_id = "${data.aws_route53_zone.ips-private.zone_id}"
  name = "${data.aws_route53_zone.ips-private.name}"
  type    = "A"

  alias {
    evaluate_target_health = false
    name = "${aws_lb.ips_lb.dns_name}"
    zone_id = "${aws_lb.ips_lb.zone_id}"
  }

  allow_overwrite = true
}
