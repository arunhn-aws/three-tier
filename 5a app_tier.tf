# Create AMI from EC2 instance
resource "aws_ami_from_instance" "app_instance_ami" {
  source_instance_id = aws_instance.app_instance.id
  name               = "MyAppInstanceAMI"

  tags = {
    Name = var.projectname
  }
}

# Create target group
resource "aws_lb_target_group" "app_target_group" {
  name     = "App-target-group"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path = "/health"
  }
}

# Create internal ALB
resource "aws_lb" "internal_alb" {
  name               = "my-internal-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.private1.id, aws_subnet.private2.id]
  security_groups    = [aws_security_group.internal_lb_sg.id]
  tags = {
    Name = "my-internal-alb"
  }
}

# Create ALB listener
resource "aws_lb_listener" "internal_alb_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Create launch template
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "my-app-launch-template"
  image_id      = aws_ami_from_instance.app_instance_ami.id
  instance_type = var.instance_type
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "app_autoscaling_group" {
  name             = "my-app-autoscaling-group"
  min_size         = 2
  max_size         = 2
  desired_capacity = 2
  launch_template {
    id = aws_launch_template.app_launch_template.id
  }
  vpc_zone_identifier = [aws_subnet.private1.id, aws_subnet.private2.id]
  target_group_arns   = [aws_lb_target_group.app_target_group.arn]
}
