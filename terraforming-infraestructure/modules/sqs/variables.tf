variable "queue_name" {
  description = "Nome da fila SQS"
  type        = string
  default     = "evaluation-service-response-sqs"
}

variable "tags" {
  description = "Tags aplicadas à fila SQS"
  type        = map(string)
  default     = {}
}