variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "secure-serverless"
}

variable "aws_account_id" {
  type = string
}

variable "cognito_domain_prefix" {
  type = string
}

variable "cognito_callback_urls" {
  type = list(string)
}

variable "cognito_logout_urls" {
  type = list(string)
}

variable "api_cors_allow_origins" {
  description = "Allowed CORS origins for prod API."
  type        = list(string)
}

variable "lambda_handler" {
  type    = string
  default = "handler.handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}

variable "lambda_memory_mb" {
  type    = number
  default = 512
}

variable "lambda_timeout_seconds" {
  type    = number
  default = 29
}

variable "dynamodb_hash_key" {
  type    = string
  default = "PK"
}

variable "dynamodb_range_key" {
  type    = string
  default = "SK"
}
