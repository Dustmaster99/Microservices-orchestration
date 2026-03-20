variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "aws_access_key_id_secret" {
  description = "AWS Access Key para o secret do Kubernetes"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key_secret" {
  description = "AWS Secret Access Key para o secret do Kubernetes"
  type        = string
  sensitive   = true
}

variable "aws_session_token_secret" {
  description = "AWS Session Token para o secret do Kubernetes"
  type        = string
  sensitive   = true
}

variable "auth_database_url" {
  type      = string
  sensitive = true
}

variable "auth_master_key" {
  type      = string
  sensitive = true
}

variable "flag_database_url" {
  type      = string
  sensitive = true
}

variable "targeting_database_url" {
  type      = string
  sensitive = true
}

variable "evaluation_service_api_key" {
  type      = string
  sensitive = true
}