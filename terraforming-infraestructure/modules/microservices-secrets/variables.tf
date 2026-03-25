variable "namespace" {
  description = "Namespace Kubernetes onde os secrets serão criados"
  type        = string
}

variable "aws_region" {
  description = "Região AWS usada pelos serviços"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS session token"
  type        = string
  sensitive   = true
}

variable "sqs_url" {
  description = "URL da fila SQS"
  type        = string
}

variable "analytics_dynamodb_table" {
  description = "Nome da tabela DynamoDB do analytics"
  type        = string
}

variable "evaluation_service_api_key" {
  description = "Chave de API do evaluation-service"
  type        = string
  sensitive   = true
}

variable "auth_database_url" {
  description = "URL de conexão do banco do auth-service"
  type        = string
  sensitive   = true
}

variable "auth_master_key" {
  description = "Master key do auth-service"
  type        = string
  sensitive   = true
}

variable "flag_database_url" {
  description = "URL de conexão do banco do flag-service"
  type        = string
  sensitive   = true
}

variable "targeting_database_url" {
  description = "URL de conexão do banco do targeting-service"
  type        = string
  sensitive   = true
}

variable "analytics_service_port" {
  description = "Porta do analytics-service"
  type        = number
}

variable "evaluation_service_port" {
  description = "Porta do evaluation-service"
  type        = number
}

variable "auth_service_port" {
  description = "Porta do auth-service"
  type        = number
}

variable "flag_service_port" {
  description = "Porta do flag-service"
  type        = number
}

variable "targeting_service_port" {
  description = "Porta do targeting-service"
  type        = number
}

variable "redis_service_port" {
  description = "Porta do serviço Redis"
  type        = number
}

variable "redis_service_name" {
  description = "Nome do service do Redis no Kubernetes"
  type        = string
}

variable "auth_service_name" {
  description = "Nome do service do auth-service no Kubernetes"
  type        = string
}

variable "flag_service_name" {
  description = "Nome do service do flag-service no Kubernetes"
  type        = string
}

variable "targeting_service_name" {
  description = "Nome do service do targeting-service no Kubernetes"
  type        = string
}