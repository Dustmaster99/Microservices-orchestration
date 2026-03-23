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


variable "analytics_service_port" {
  description = "Porta do analytics-service"
  type        = number
  default     = 8005
}

variable "auth_service_name" {
  description = "Nome do Service Kubernetes do auth-service"
  type        = string
  default     = "auth-service"
}

variable "auth_service_port" {
  description = "Porta do auth-service"
  type        = number
  default     = 8001
}

variable "flag_service_name" {
  description = "Nome do Service Kubernetes do flag-service"
  type        = string
  default     = "flag-service"
}

variable "flag_service_port" {
  description = "Porta do flag-service"
  type        = number
  default     = 8002
}

variable "targeting_service_name" {
  description = "Nome do Service Kubernetes do targeting-service"
  type        = string
  default     = "targeting-service"
}

variable "targeting_service_port" {
  description = "Porta do targeting-service"
  type        = number
  default     = 8003
}

variable "evaluation_service_port" {
  description = "Porta do evaluation-service"
  type        = number
  default     = 8004
}

variable "redis_service_name" {
  description = "Nome do Service Kubernetes do Redis"
  type        = string
  default     = "redis-service"
}

variable "redis_service_port" {
  description = "Porta do Service Kubernetes do Redis"
  type        = number
  default     = 6379
}

variable "redis_port" {
  description = "Porta exposta pelo container Redis"
  type        = number
  default     = 6379
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID usado pelos serviços"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key usado pelos serviços"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token usado pelos serviços"
  type        = string
  sensitive   = true
}

variable "analytics_service_name" {
  description = "Nome do analytics-service"
  type        = string
  default     = "analytics-service"
}

variable "evaluation_service_name" {
  description = "Nome do evaluation-service"
  type        = string
  default     = "evaluation-service"
}

variable "redis_deployment_name" {
  description = "Nome do deployment Redis"
  type        = string
  default     = "redis-deployment"
}

variable "redis_app_name" {
  description = "Label app do Redis"
  type        = string
  default     = "redis-server"
}

variable "redis_container_name" {
  description = "Nome do container Redis"
  type        = string
  default     = "redis-server"
}
variable "sqs_url" {
  description = "URL da fila SQS usada pelo evaluation-service"
  type        = string
}

variable "image_tag_redis" {
  description = "Tag da imagem do Redis"
  type        = string
  default     = "7"
}