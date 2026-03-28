output "function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "Lambda function ARN."
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Lambda invoke ARN (used by API Gateway integrations)."
  value       = aws_lambda_function.this.invoke_arn
}

output "execution_role_arn" {
  description = "IAM execution role ARN for the Lambda function."
  value       = aws_iam_role.lambda_exec.arn
}

output "log_group_name" {
  description = "CloudWatch log group name for this function."
  value       = aws_cloudwatch_log_group.lambda.name
}
