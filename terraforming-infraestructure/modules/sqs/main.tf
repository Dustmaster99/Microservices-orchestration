resource "aws_sqs_queue" "evaluation_response_queue" {
  name = var.queue_name

  tags = var.tags
}