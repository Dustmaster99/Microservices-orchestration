variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}