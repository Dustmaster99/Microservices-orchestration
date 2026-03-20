variable "public_subnet_ids" {
  description = "Subnets públicas usadas pelo Load Balancer"
  type        = list(string)
}

variable "aws_access_key_id_secret" {
  description = "AWS Access Key para o secret"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key_secret" {
  description = "AWS Secret Access Key para o secret"
  type        = string
  sensitive   = true
}

variable "aws_session_token_secret" {
  description = "AWS Session Token para o secret"
  type        = string
  sensitive   = true
}