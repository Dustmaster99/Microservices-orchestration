resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-database-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(
    {
      Name = "${var.project_name}-database-subnet-group"
    },
    var.tags
  )
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from inside VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_name}-rds-sg"
    },
    var.tags
  )
}

resource "aws_db_instance" "auth_service_db" {
  identifier             = "auth-service-db"
  db_name                = "auth_db"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = "postgres"
  password               = var.auth_master_key
  port                   = 5432

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  apply_immediately      = true

  tags = merge(
    {
      Name = "auth-service-db"
    },
    var.tags
  )
}

resource "aws_db_instance" "flag_service_db" {
  identifier             = "flag-service-db"
  db_name                = "flags_db"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = "postgres"
  password               = var.flag_master_key
  port                   = 5432

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  apply_immediately      = true

  tags = merge(
    {
      Name = "flag-service-db"
    },
    var.tags
  )
}

resource "aws_db_instance" "targeting_service_db" {
  identifier             = "targeting-service-db"
  db_name                = "targeting_db"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = "postgres"
  password               = var.targeting_master_key
  port                   = 5432

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  apply_immediately      = true

  tags = merge(
    {
      Name = "targeting-service-db"
    },
    var.tags
  )
}