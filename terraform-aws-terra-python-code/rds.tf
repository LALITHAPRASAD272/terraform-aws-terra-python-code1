# ---------------- RDS Subnet Group ----------------
resource "aws_db_subnet_group" "db_subnet" {
  name       = "my-db-subnet-group"
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}

# ---------------- RDS MySQL ----------------
resource "aws_db_instance" "mysql" {
  identifier         = "myappdb"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20

  db_name            = "studentdb"
  username           = "admin"
  password           = "Admin1234!"

  port               = 3306

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false

  multi_az = false
}