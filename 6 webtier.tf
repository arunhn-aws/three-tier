# Resource for AWS EC2 instance
resource "aws_instance" "web_instance" {
  ami                         = var.ami               # Update with your desired AMI ID
  instance_type               = var.instance_type     # Update with your desired instance type
  subnet_id                   = aws_subnet.public1.id # Update with the ID of your public subnet
  associate_public_ip_address = true                  # Auto-assign public IP to the instance
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "web-instance" # Update with your desired name tag
  }

  # Security group configuration allowing SSH and HTTP traffic
  security_groups = [aws_security_group.web_tier_sg.id] # Update with your security group ID(s)

  # User data to execute configuration steps on instance launch
  user_data = <<-EOF
                #!/bin/bash
                # Install NVM and Node.js
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
                source ~/.bashrc
                nvm install 16
                nvm use 16
                
                # Download web tier code from S3 bucket
                cd ~/
                aws s3 cp s3://${var.bucket_name}/web-tier/ web-tier --recursive
                
                # Navigate to web-layer folder and build React app
                cd ~/web-tier
                npm install 
                npm run build
                
                # Install NGINX
                sudo amazon-linux-extras install nginx1 -y
                
                # Configure NGINX
                sudo rm /etc/nginx/nginx.conf
                sudo aws s3 cp s3://${var.bucket_name}/nginx.conf /etc/nginx/nginx.conf
                sudo service nginx restart
                
                # Set permissions for Nginx access
                sudo chmod -R 755 /home/ec2-user
                
                # Enable Nginx to start on boot
                sudo chkconfig nginx on
              EOF
}