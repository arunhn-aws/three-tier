resource "aws_db_instance" "my_database" {
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  username                = var.db_username
  password                = var.db_password
  identifier              = "my-database"
  parameter_group_name    = "default.mysql5.7"
  allocated_storage       = 20
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_instance_sg.id]
  backup_retention_period = 7
  skip_final_snapshot     = true
  multi_az                = true # Enable Multi-AZ deployment


}

#resource "aws_db_instance" "my_database_replica" {
# Configuration for the replica instance in the same subnet group
#  engine                  = aws_db_instance.my_database.engine
#  engine_version          = aws_db_instance.my_database.engine_version
#  instance_class          = aws_db_instance.my_database.instance_class
#  password                = aws_db_instance.my_database.password
#  publicly_accessible     = aws_db_instance.my_database.publicly_accessible
#  vpc_security_group_ids  = [aws_security_group.db_instance_sg.id]
#  replicate_source_db     = aws_db_instance.my_database.identifier
#  backup_retention_period = 7
#  skip_final_snapshot     = true
#  multi_az                = true  # Enable Multi-AZ deployment

# }
