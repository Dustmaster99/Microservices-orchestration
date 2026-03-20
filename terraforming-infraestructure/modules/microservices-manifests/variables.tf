variable "namespace" {
  description = "Namespace dos microserviços"
  type        = string
  default     = "fiap-microservices"
}

variable "aws_region" {
  description = "Região AWS usada pelos serviços"
  type        = string
}

variable "ecr_registry" {
  description = "Registry base do ECR"
  type        = string
}

variable "image_tag" {
  description = "Tag das imagens"
  type        = string
  default     = "latest"
}

variable "analytics_aws_sqs_url" {
  description = "URL da fila SQS usada pelo analytics"
  type        = string
}

variable "analytics_dynamodb_table" {
  description = "Tabela DynamoDB usada pelo analytics"
  type        = string
}

variable "auth_database_url" {
  description = "URL do banco do auth-service"
  type        = string
  sensitive   = true
}

variable "auth_master_key" {
  description = "Master key do auth-service"
  type        = string
  sensitive   = true
}

variable "flag_database_url" {
  description = "URL do banco do flag-service"
  type        = string
  sensitive   = true
}

variable "targeting_database_url" {
  description = "URL do banco do targeting-service"
  type        = string
  sensitive   = true
}

variable "evaluation_service_api_key" {
  description = "API key do evaluation-service"
  type        = string
  sensitive   = true
}

variable "evaluation_aws_sqs_url" {
  description = "URL da fila SQS usada pelo evaluation-service"
  type        = string
}