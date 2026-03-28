# ---------------------------------------------------------------------------
# Root outputs — surface the most-needed values after a successful apply.
# ---------------------------------------------------------------------------

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID."
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito App Client ID."
  value       = module.cognito.user_pool_client_id
  sensitive   = true
}

output "cognito_hosted_ui_url" {
  description = "Cognito hosted-UI login URL."
  value       = module.cognito.hosted_ui_url
}

output "api_endpoint" {
  description = "HTTP API Gateway invoke URL."
  value       = module.api.api_endpoint
}

output "lambda_function_name" {
  description = "Lambda function name."
  value       = module.lambda.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = module.dynamodb.table_name
}

output "cloudtrail_trail_arn" {
  description = "CloudTrail trail ARN."
  value       = module.cloudtrail.trail_arn
}

output "waf_web_acl_arn" {
  description = "WAFv2 Web ACL ARN."
  value       = module.waf.web_acl_arn
}
