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

variable "auth_master_key" {
  type      = string
  sensitive = true
}

variable "flag_master_key" {
  type      = string
  sensitive = true
}

variable "targeting_master_key" {
  type      = string
  sensitive = true
}

output "auth_database_url" {
  value     = module.rds.auth_database_url
  sensitive = true
}

output "flag_database_url" {
  value     = module.rds.flag_database_url
  sensitive = true
}

output "targeting_database_url" {
  value     = module.rds.targeting_database_url
  sensitive = true
}

variable "evaluation_service_api_key" {
  type      = string
  sensitive = true
}


variable "analytics_dynamodb_table" {
  description = "Nome da tabela DynamoDB usada pelo analytics service"
  type        = string
}


variable "image_tag" {
  description = "Tag das imagens"
  type        = string
  default     = "latest"
}

variable "analytics_service_port" {
  description = "Porta do analytics-service"
  type        = number
  default     = 8005
}

variable "auth_service_name" {
  description = "Nome do service do auth"
  type        = string
  default     = "auth-service"
}

variable "auth_service_port" {
  description = "Porta do auth-service"
  type        = number
  default     = 8001
}

variable "flag_service_name" {
  description = "Nome do service do flag"
  type        = string
  default     = "flag-service"
}

variable "flag_service_port" {
  description = "Porta do flag-service"
  type        = number
  default     = 8002
}

variable "targeting_service_name" {
  description = "Nome do service do targeting"
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


variable "redis_service_port" {
  description = "Porta do service do Redis"
  type        = number
  default     = 6379
}

variable "analytics_service_name" {
  description = "Nome do service do analytics"
  type        = string
  default     = "analytics-service"
}

variable "evaluation_service_name" {
  description = "Nome do service do evaluation"
  type        = string
  default     = "evaluation-service"
}

variable "image_tag_redis" {
  description = "Tag da imagem do Redis"
  type        = string
  default     = "7"
}

variable "argocd_chart_version" {
  description = "Versão do Helm chart do ArgoCD."
  type        = string
  default     = "7.6.12"
}
