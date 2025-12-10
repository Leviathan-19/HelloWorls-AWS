resource "aws_launch_template" "app" {
  name_prefix   = "hello"
  image_id      = "ami-08df7e9cff92a2aac"
  instance_type = "t3.micro"
  key_name      = "nginx-server-ssh"

  vpc_security_group_ids = [aws_security_group.web.id]
}

resource "aws_autoscaling_group" "app" {
  max_size          = 10
  min_size          = 3
  desired_capacity  = 3

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  # Etiquetas útiles para identificar instancias
  tag {
    key                 = "Name"
    value               = "hello-app-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_on_cpu" {
  name                   = "scale-out-on-high-cpu"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_autoscaling_policy" "scale_on_request_count" {
  name                   = "scale-out-on-high-request-count"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.app.arn_suffix}/${aws_lb_target_group.app.arn_suffix}"
    }
    target_value = 500.0
  }
}