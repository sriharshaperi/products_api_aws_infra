# # Provider configuration for AWS account 2
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.ec2-webapp-dev.id
  vpc      = true
}
resource "aws_route53_record" "peri_A_record" {
  zone_id = var.aws_profile == "dev" ? var.r53_dev_zone_id : var.r53_prod_zone_id
  name    = var.aws_profile == "dev" ? var.r53_dev_name : var.r53_prod_name
  type    = "A"
  # ttl     = 60
  # records = [aws_eip.elastic_ip.public_ip]
  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}
