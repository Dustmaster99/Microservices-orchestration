variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes no EKS"
  type        = string
  default     = "1.30"
}

variable "cluster_role_arn" {
  description = "ARN da role IAM do cluster EKS"
  type        = string
}

variable "node_role_arn" {
  description = "ARN da role IAM dos nodes do EKS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas do cluster"
  type        = list(string)
}

variable "node_group_name" {
  description = "Nome do node group"
  type        = string
  default     = "eks-node-group"
}

variable "instance_types" {
  description = "Tipos de instância dos worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "capacity_type" {
  description = "Tipo de capacidade do node group"
  type        = string
  default     = "SPOT"
}

variable "disk_size" {
  description = "Tamanho do disco dos nodes em GB"
  type        = number
  default     = 20
}

variable "desired_size" {
  description = "Quantidade desejada inicial de nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Quantidade mínima de nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Quantidade máxima de nodes"
  type        = number
  default     = 2
}

variable "max_unavailable" {
  description = "Quantidade máxima de nodes indisponíveis em updates"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}

