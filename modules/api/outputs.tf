output "api_id" {
  description = "HTTP API Gateway ID."
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "HTTP API Gateway invoke URL."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_execution_arn" {
  description = "API execution ARN (used by WAF association)."
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage_arn" {
  description = "ARN of the $default stage (used to associate WAF web ACL)."
  value       = "${aws_apigatewayv2_stage.default.execution_arn}/*"
}

output "access_log_group_name" {
  description = "CloudWatch log group for API access logs."
  value       = aws_cloudwatch_log_group.api_access.name
}
