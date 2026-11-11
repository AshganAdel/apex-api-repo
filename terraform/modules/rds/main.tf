resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"

  subnet_ids = var.private_subnets_ids

  tags = {
    Name = "rds-subnet-group"
  }
}


resource "aws_db_instance" "postgres" {
  identifier = "my-postgres-db"

  engine         = "postgres"
  engine_version = "16"

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = "appdb"
  username = "postgres"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.sg_group_id]

  port = 5432

  publicly_accessible = false
  multi_az            = false

  storage_encrypted = true
  skip_final_snapshot = true


  tags = {
    Name = "my-postgres-db"
  }
}