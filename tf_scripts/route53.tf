resource "aws_route53_record" "example" {
  zone_id = var.r53_zone_id
  name    = var.r53_name
  type    = var.r53_type
  ttl     = var.r53_ttl

  records = [
    "${aws_instance.ec2-webapp-dev.public_ip}",
  ]
}