resource "aws_instance" "app_instance" {
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.private1.id
  security_groups      = [aws_security_group.private_instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data            = <<-EOF
                          #!/bin/bash
                          sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                          sudo systemctl start amazon-ssm-agent
                          sudo systemctl enable amazon-ssm-agent
                          EOF

  tags = {
    Name = "App Instance"
  }
}
