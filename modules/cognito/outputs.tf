output "user_pool_id" {
  description = "Cognito User Pool ID."
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN."
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint (issuer hostname, without scheme)."
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_client_id" {
  description = "Cognito App Client ID."
  value       = aws_cognito_user_pool_client.this.id
  sensitive   = true
}

output "hosted_ui_url" {
  description = "Cognito hosted-UI login URL."
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

data "aws_region" "current" {}
