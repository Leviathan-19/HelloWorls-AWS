resource "aws_launch_template" "app" {
  name_prefix   = "hello"
  image_id      = "ami-08df7e9cff92a2aac"
  instance_type = "t3.micro"
  key_name      = "nginx-server-ssh"

  # Use vpc_security_group_ids instead of explicit network_interfaces so Auto Scaling
  # will create ENIs in the selected subnets. Public IP allocation will come from
  # the subnet attribute `map_public_ip_on_launch = true` (see `vpc.tf`).
  vpc_security_group_ids = [aws_security_group.web.id]
}


resource "aws_autoscaling_group" "app" {
  max_size = 9
  min_size = 3
  desired_capacity = 3

  launch_template {
    id = aws_launch_template.app.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]

  # Perform a rolling instance refresh when the launch template changes so new
  # instances pick up the updated key_name / security group / userdata.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup         = 120
    }
  }
}
