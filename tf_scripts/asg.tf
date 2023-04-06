resource "aws_launch_configuration" "asg_launch_config" {
  name_prefix                 = "asg_launch_config"
  image_id                    = aws_instance.ec2-webapp-dev.ami
  instance_type               = var.instance_type
  key_name                    = var.aws_keypair_dev
  associate_public_ip_address = true
  user_data                   = base64encode(local.user_data)
  iam_instance_profile        = aws_iam_instance_profile.s3_access_instance_profile.name
  security_groups             = [aws_security_group.application.id]
  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch metric alarm for CPU usage scale up policy
resource "aws_cloudwatch_metric_alarm" "cpu_usage_scale_up" {
  alarm_name          = "cpu-usage-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
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
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
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
  name_prefix          = "webapp_asg"
  launch_configuration = aws_launch_configuration.asg_launch_config.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = [for subnet in aws_subnet.private_subnets : subnet.id]
  target_group_arns    = [aws_lb_target_group.webapp_tg.arn]

  tags = [
    {
      key                 = "Name"
      value               = "ASG instance"
      propagate_at_launch = true
    }
  ]
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
