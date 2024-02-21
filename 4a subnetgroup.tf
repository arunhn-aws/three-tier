resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "my-db-subnet-group"
  description = "My DB Subnet Group"
  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id,
  ]
}
