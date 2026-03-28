output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value     = module.cognito.user_pool_client_id
  sensitive = true
}

output "cognito_hosted_ui_url" {
  value = module.cognito.hosted_ui_url
}

output "api_endpoint" {
  value = module.api.api_endpoint
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "cloudtrail_trail_arn" {
  value = module.cloudtrail.trail_arn
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}
