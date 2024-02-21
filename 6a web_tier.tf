
# Resource to create an AMI from the web tier instance
resource "aws_ami_from_instance" "web_tier_ami" {
  name               = "WebTierAMI"                 # Name for the AMI
  source_instance_id = aws_instance.web_instance.id # ID of the web tier instance
  # Optionally, specify additional parameters like description, tags, etc.
}

# Resource to create a target group
resource "aws_lb_target_group" "web_tier_target_group" {
  name        = "WebTierTargetGroup" # Name for the target group
  port        = 80                   # Port on which NGINX is listening
  protocol    = "HTTP"               # Protocol for the target group
  target_type = "instance"           # Type of targets (in this case, instances)

  vpc_id = aws_vpc.main.id # ID of the VPC

  health_check {
    path                = "/health" # Health check path
    interval            = 30        # Health check interval in seconds
    timeout             = 5         # Health check timeout in seconds
    healthy_threshold   = 2         # Number of consecutive successful health checks required to mark a target as healthy
    unhealthy_threshold = 2         # Number of consecutive failed health checks required to mark a target as unhealthy
  }
}

# Resource to create an ALB
resource "aws_lb" "web_tier_alb" {
  name               = "webtierALB"  # Name for the ALB
  internal           = false         # Set to false for internet-facing ALB
  load_balancer_type = "application" # Type of load balancer (application for ALB)

  subnets = [aws_subnet.public1.id, aws_subnet.public2.id] # IDs of the public subnets

  security_groups = [aws_security_group.ext_lb_sg.id] # ID of the security group for the ALB

  enable_deletion_protection = false # Optionally set deletion protection to false

  tags = {
    Name = "webtieralb" # Tags for the ALB
  }
}


# Resource to create a launch template
resource "aws_launch_template" "web_tier_launch_template" {
  name          = "WebTierLaunchTemplate"               # Name for the launch template
  image_id      = aws_ami_from_instance.web_tier_ami.id # ID of the AMI you created earlier
  instance_type = var.instance_type                     # Instance type for the launch template
  # Optionally, specify additional parameters like security group, IAM instance profile, etc.


  # Define IAM instance profile for the launch template
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name # Name of the IAM instance profile
  }

  # Optionally, define tags for the launch template
  tags = {
    Name = "WebTierLaunchTemplate" # Tags for the launch template
  }
}

# Resource to create an Auto Scaling Group
resource "aws_autoscaling_group" "web_tier_asg" {
  name = "WebTierASG" # Name for the ASG
  launch_template {
    id      = aws_launch_template.web_tier_launch_template.id # ID of the launch template
    version = "$Latest"                                       # Use the latest version of the launch template
  }
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]  # IDs of the public subnets
  target_group_arns   = [aws_lb_target_group.web_tier_target_group.arn] # ARN of the target group
  min_size            = 2                                               # Minimum number of instances
  max_size            = 2                                               # Maximum number of instances
  desired_capacity    = 2                                               # Desired number of instances
}