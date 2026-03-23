output "queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.evaluation_response_queue.url
}

output "queue_arn" {
  description = "ARN da fila SQS"
  value       = aws_sqs_queue.evaluation_response_queue.arn
}

output "queue_name" {
  description = "Nome da fila SQS"
  value       = aws_sqs_queue.evaluation_response_queue.name
}