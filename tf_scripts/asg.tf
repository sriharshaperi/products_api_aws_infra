resource "aws_launch_template" "asg_launch_template" {
  name = "asg-launch-template"
  # vpc_security_group_ids = [aws_security_group.application.id]
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application.id]
    # subnet_id                   = aws_subnet.public_subnets[0].id
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.encryption_key_ebs.arn
    }
  }

  image_id                = data.aws_ami.latest_ami.id
  instance_type           = var.instance_type
  key_name                = var.aws_keypair_dev
  user_data               = base64encode(local.user_data)
  disable_api_termination = false
  ebs_optimized           = false
  iam_instance_profile {
    arn = aws_iam_instance_profile.s3_access_instance_profile.arn
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.ec2_tag_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_launch_configuration" "asg_launch_config" {
#   name_prefix                 = "asg_launch_config"
#   image_id                    = aws_instance.ec2-webapp-dev.ami
#   instance_type               = var.instance_type
#   key_name                    = var.aws_keypair_dev
#   associate_public_ip_address = true
#   user_data                   = base64encode(local.user_data)
#   iam_instance_profile        = aws_iam_instance_profile.s3_access_instance_profile.name
#   security_groups             = [aws_security_group.application.id]
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# CloudWatch metric alarm for CPU usage scale up policy
resource "aws_cloudwatch_metric_alarm" "cpu_usage_scale_up" {
  alarm_name          = "cpu-usage-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "Scale up when average CPU usage is above 5%"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scale_up_policy.arn}"]
}

# CloudWatch metric alarm for CPU usage scale down policy
resource "aws_cloudwatch_metric_alarm" "cpu_usage_scale_down" {
  alarm_name          = "cpu-usage-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "3"
  alarm_description   = "Scale down when average CPU usage is below 3%"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scale_down_policy.arn}"]
}

resource "aws_autoscaling_group" "webapp_asg" {
  name = "webapp_asg"
  # launch_configuration = aws_launch_configuration.asg_launch_config.id
  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }

  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]
  target_group_arns   = [aws_lb_target_group.webapp_tg.arn]
  health_check_type   = "EC2"
  tags = [
    {
      key                 = "Name"
      value               = "ASG instance"
      propagate_at_launch = true
    }
  ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_policy" "scale_up_policy" {
  name                    = "cpu-usage-scale-up"
  policy_type             = "SimpleScaling"
  autoscaling_group_name  = aws_autoscaling_group.webapp_asg.name
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Average"
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                    = "cpu-usage-scale-down"
  policy_type             = "SimpleScaling"
  autoscaling_group_name  = aws_autoscaling_group.webapp_asg.name
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Average"
}
