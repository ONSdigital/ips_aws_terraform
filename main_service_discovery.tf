//resource "aws_service_discovery_private_dns_namespace" "ips_servs_sd_dns" {
//  name        = "${local.common_name_prefix}-ips-servs-dns"
//  description = "This is the terraformed private service discovery dns namespace"
//  vpc         = "${aws_vpc.main_vpc.id}"
//}
//
//resource "aws_service_discovery_service" "ips_servs_sd" {
//  name = "${local.common_name_prefix}-ips-servs"
//
//  dns_config {
//    namespace_id = "${aws_service_discovery_private_dns_namespace.ips_servs_sd_dns.id}"
//
//    dns_records {
//      ttl  = 60
//      type = "A"
//    }
//
////    routing_policy = "MULTIVALUE"
//  }
//
////  health_check_custom_config {
////    failure_threshold = 1
////  }
//}
//
