variable "table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
  default     = "ToggleMasterAnalytics"
}

variable "billing_mode" {
  description = "Modo de cobrança da tabela DynamoDB"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Chave primária (partition key) da tabela"
  type        = string
  default     = "id"
}

variable "hash_key_type" {
  description = "Tipo da chave primária: S, N ou B"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "hash_key_type deve ser S, N ou B."
  }
}

variable "tags" {
  description = "Tags aplicadas à tabela"
  type        = map(string)
  default     = {}
}