# security group - Internet facing External load balancer

resource "aws_security_group" "ext_lb_sg" {
  name        = "Internet_facing_lb_sg"
  description = "External Loadbalancer security group for Internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Internet_facing_lb_sg"
  }
}

# security group - web tier

resource "aws_security_group" "web_tier_sg" {
  name        = "web_tier_sg"
  description = "Web tier Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "TLS from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ext_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_tier_sg"
  }
}

# Security group for the internal load balancer
resource "aws_security_group" "internal_lb_sg" {
  name        = "internal-lb-sg"
  description = "Security group for the internal load balancer"

  vpc_id = aws_vpc.main.id # Assuming you have a VPC resource named "main"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Security group for the private instances
resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_sg"
  description = "Security group for the private instances"
  vpc_id      = aws_vpc.main.id # Assuming you have a VPC resource named "main"

  # Inbound rule allowing TCP traffic from the internal load balancer security group on port 4000
  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }

  # Outbound rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_instance_sg"
  }
}

# Security group for the private database instances
resource "aws_security_group" "db_instance_sg" {
  name        = "db_instance_sg"
  description = "Security group for the private database instances"
  vpc_id      = aws_vpc.main.id # Assuming you have a VPC resource named "main"

  # Inbound rule allowing traffic from the private instance security group to MySQL/Aurora port
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_instance_sg.id] # Replace private_instance_sg with the actual name or ID of your private instance security group
  }

  # Outbound rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_instance_sg"
  }
}

