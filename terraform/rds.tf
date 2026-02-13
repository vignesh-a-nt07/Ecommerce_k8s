resource "aws_db_subnet_group" "db" {
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"

  db_subnet_group_name            = aws_db_subnet_group.db.name
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  publicly_accessible             = false
  skip_final_snapshot             = true
  backup_window                   = "03:00-04:00"
  backup_retention_period         = 7
  auto_minor_version_upgrade      = true
  multi_az                        = false
  storage_encrypted               = false
}
