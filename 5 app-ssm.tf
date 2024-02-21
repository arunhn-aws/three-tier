resource "aws_ssm_document" "install_and_configure_app" {
  name            = "InstallAndConfigureApp"
  document_type   = "Command"
  document_format = "YAML"

  content = <<-YAML
---
schemaVersion: "2.2"
description: "Installs and configures the application instance"
mainSteps:
  - action: "aws:runShellScript"
    name: "install_and_configure_app"
    inputs:
      runCommand:
        - "sudo yum install mysql -y"
        - "mysql -h ${aws_db_instance.my_database.endpoint} -u ${var.db_username} -p ${var.db_password} -e 'CREATE DATABASE webappdb;'"
        - "mysql -h ${aws_db_instance.my_database.endpoint} -u ${var.db_username} -p ${var.db_password} -e 'USE webappdb; CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));'"
        - "mysql -h ${aws_db_instance.my_database.endpoint} -u ${var.db_username} -p ${var.db_password} -e \"INSERT INTO transactions (amount,description) VALUES ('400','groceries');\""
        - "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash"
        - "source ~/.bashrc"
        - "nvm install 16"
        - "nvm use 16"
        - "npm install -g pm2"
        - "cd ~"
        - "aws s3 cp s3://${var.bucket_name}/app-tier/ app-tier --recursive"
        - "cd ~/app-tier"
        - "npm install"
        - "pm2 start index.js"
        - "pm2 startup"
        - "pm2 save"
        
YAML
}

resource "aws_ssm_association" "install_and_configure_app" {
  name = aws_ssm_document.install_and_configure_app.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.app_instance.id] # Replace with the actual instance ID(s)
  }
}
