locals {
  user_data = templatefile("${path.module}/user_data.tpl", {
    NODE_ENV       = "dev"
    PORT           = 3000
    DIALECT        = "mysql"
    DB_HOST        = element(split(":", aws_db_instance.rds_instance.endpoint), 0)
    DB_USERNAME    = aws_db_instance.rds_instance.username
    DB_PASSWORD    = aws_db_instance.rds_instance.password
    DB_NAME        = aws_db_instance.rds_instance.db_name
    S3_BUCKET_NAME = aws_s3_bucket.webapp-s3.bucket
    AWS_REGION     = var.aws_region
  })
}

resource "aws_security_group" "load_balancer_sg" {
  name_prefix = "load_balancer_sg"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name        = "webapp-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 60
    path              = "/healthz"
    port              = 3000
    timeout           = 30
  }

}

# resource "aws_lb_target_group_attachment" "webapp_alb_tg_attachment" {
#   target_group_arn = aws_lb_target_group.webapp_tg.arn
#   target_id        = aws_instance.ec2-webapp-dev.id
#   port             = 3000
# }

resource "aws_lb" "webapp_alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]
}

data "aws_acm_certificate" "prod_pericsye_me_certificate" {
  domain   = "prod.pericsye.me"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "webapp_alb_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 443
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
  ssl_policy      = var.ssl_policy
  certificate_arn = var.certificate_arn
}
