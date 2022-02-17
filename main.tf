# ===========================================================
# Main Terraform File
# ===========================================================

# ===========================================================
# Resource Blocks
# ===========================================================

# AWS LC
resource "aws_launch_configuration" "webapp_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = "poc-lc-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.e2Type

  security_groups = [
    "${aws_security_group.webapp_http_inbound_sg.id}",
    "${aws_security_group.webapp_ssh_inbound_sg.id}",
    "${aws_security_group.webapp_outbound_sg.id}",
  ]

  user_data                   = file("./Scripts/userdata.sh")
  key_name                    = var.key_name
  associate_public_ip_address = true
  depends_on = [
    aws_security_group.webapp_http_inbound_sg,
    aws_security_group.webapp_ssh_inbound_sg,
    aws_security_group.webapp_outbound_sg
  ]
}

# AWS ASG
resource "aws_autoscaling_group" "webapp_asg" {
  lifecycle {
    create_before_destroy = true
  }

  vpc_zone_identifier  = module.vpc.public_subnets
  name                 = "webapp_asg"
  max_size             = var.asg_max
  min_size             = var.asg_min
  force_delete         = true
  launch_configuration = aws_launch_configuration.webapp_lc.id
  load_balancers       = ["${aws_elb.webapp-elb.name}"]

}

#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg_scale_up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "high-asg-cpu"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg_scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "low-asg-cpu"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]
}