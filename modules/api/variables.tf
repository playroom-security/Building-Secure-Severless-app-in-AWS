variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda invoke ARN for the default route integration."
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name (used to grant invocation permission)."
  type        = string
}

variable "cognito_user_pool_endpoint" {
  description = "Cognito user pool endpoint (issuer URL for JWT authorizer)."
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "Cognito app client ID (JWT authorizer audience)."
  type        = string
}

variable "cors_allow_origins" {
  description = "List of allowed CORS origins."
  type        = list(string)
  default     = ["*"]
}

variable "throttling_burst_limit" {
  description = "API default route throttle burst limit."
  type        = number
  default     = 500
}

variable "throttling_rate_limit" {
  description = "API default route throttle rate limit (requests/sec)."
  type        = number
  default     = 1000
}

variable "log_retention_days" {
  description = "CloudWatch access log retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to API Gateway resources."
  type        = map(string)
  default     = {}
}
