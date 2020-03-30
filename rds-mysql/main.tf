resource "aws_db_parameter_group" "default" {
  name   = var.name
  family = var.parameter_group_family

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "skip-character-set-client-handshake"
    value = 1
    apply_method = "pending-reboot" 
  }
}

resource "aws_db_option_group" "default" {
  name                 = var.name
  engine_name          = var.engine_name
  major_engine_version = var.major_engine_version
}

resource "aws_db_subnet_group" "default" {
  name       = var.name
  subnet_ids = var.db_subnet_ids
}

module "mysql_sg" {
  source      = "./security_group"
  name        = "rds-${var.name}"
  vpc_id      = var.vpc_id
  port        = 3306
  cidr_blocks = [var.vpc_cidr_block]
  sg_id = var.sg_id
}

resource "aws_db_instance" "default" {
  identifier              = var.name
  allocated_storage       = var.db_allocated_storage
  # NOTE: 汎用SSD固定
  storage_type            = "gp2"
  max_allocated_storage   = var.db_max_allocated_storage
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  backup_retention_period = 1
  vpc_security_group_ids  = [module.mysql_sg.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  depends_on = [aws_db_subnet_group.default, module.mysql_sg]
  skip_final_snapshot     = var.skip_final_snapshot
  parameter_group_name = aws_db_parameter_group.default.name
}