output "auth_database_url" {
  description = "Connection URL for auth database"
  value       = "postgresql://postgres:${var.auth_master_key}@${aws_db_instance.auth_service_db.address}:${aws_db_instance.auth_service_db.port}/${aws_db_instance.auth_service_db.db_name}"
  sensitive   = true
}

output "flag_database_url" {
  description = "Connection URL for flag database"
  value       = "postgresql://postgres:${var.flag_master_key}@${aws_db_instance.flag_service_db.address}:${aws_db_instance.flag_service_db.port}/${aws_db_instance.flag_service_db.db_name}"
  sensitive   = true
}

output "targeting_database_url" {
  description = "Connection URL for targeting database"
  value       = "postgresql://postgres:${var.targeting_master_key}@${aws_db_instance.targeting_service_db.address}:${aws_db_instance.targeting_service_db.port}/${aws_db_instance.targeting_service_db.db_name}"
  sensitive   = true
}

output "database_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.database.name
}

output "rds_security_group_id" {
  description = "Security group ID used by RDS instances"
  value       = aws_security_group.rds.id
}