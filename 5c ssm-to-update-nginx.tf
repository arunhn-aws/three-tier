resource "aws_ssm_document" "update_nginx_config" {
  name          = "update_nginx_config"
  document_type = "Command"

  content = <<-EOF
    {
      "schemaVersion": "2.2",
      "description": "Update nginx configuration",
      "mainSteps": [
        {
          "action": "aws:runShellScript",
          "name": "updateNginxConfig",
          "inputs": {
            "runCommand": [
              "sed -i 's/\\[dns of the load balancer\\]/${aws_lb.internal_alb.dns_name}/g' ~/app-tier/nginx.conf",
              "EXIT_STATUS=$?",
              "if [ $EXIT_STATUS -ne 0 ]; then echo 'Error updating nginx.conf' >> /var/log/nginx_update.log; fi"
            ]
          }
        }
      ]
    }
  EOF
}

resource "aws_ssm_association" "app_instance_association" {
  name = aws_ssm_document.update_nginx_config.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.app_instance.id]
  }
}
