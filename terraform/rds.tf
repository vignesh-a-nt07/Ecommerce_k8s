resource "aws_db_subnet_group" "db" {
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "postgres" {
  engine            = "postgres"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
}
