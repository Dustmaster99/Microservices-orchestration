variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR allowed to reach PostgreSQL"
  type        = string
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "auth_master_key" {
  description = "Master password used for all PostgreSQL instances"
  type        = string
  sensitive   = true
}

variable "flag_master_key" {
  description = "Master password used for all PostgreSQL instances"
  type        = string
  sensitive   = true
}

variable "targeting_master_key" {
  description = "Master password used for all PostgreSQL instances"
  type        = string
  sensitive   = true
}


variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}