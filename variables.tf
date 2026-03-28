# ---------------------------------------------------------------------------
# Root-level variables shared across every environment composition.
# Environments override these in their own terraform.tfvars.
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy all resources into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "app_name" {
  description = "Short application name used as a prefix in resource naming."
  type        = string
  default     = "secure-serverless"
}

variable "aws_account_id" {
  description = "AWS account ID used to scope IAM and bucket policies."
  type        = string
}

# ---------------------------------------------------------------------------
# Cognito
# ---------------------------------------------------------------------------

variable "cognito_domain_prefix" {
  description = "Cognito hosted-UI domain prefix (globally unique, lowercase alphanumeric/hyphens)."
  type        = string
}

variable "cognito_callback_urls" {
  description = "List of allowed OAuth callback URLs for the Cognito app client."
  type        = list(string)
  default     = ["https://localhost:3000/callback"]
}

variable "cognito_logout_urls" {
  description = "List of allowed OAuth sign-out URLs for the Cognito app client."
  type        = list(string)
  default     = ["https://localhost:3000/logout"]
}

# ---------------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------------

variable "lambda_source_dir" {
  description = "Path to the Lambda source directory whose contents will be zipped."
  type        = string
  default     = "src/lambda"
}

variable "lambda_handler" {
  description = "Lambda handler in handler.function format."
  type        = string
  default     = "handler.handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "python3.12"
}

variable "lambda_memory_mb" {
  description = "Lambda function memory size in MB."
  type        = number
  default     = 256
}

variable "lambda_timeout_seconds" {
  description = "Lambda function execution timeout in seconds."
  type        = number
  default     = 29
}

# ---------------------------------------------------------------------------
# DynamoDB
# ---------------------------------------------------------------------------

variable "dynamodb_hash_key" {
  description = "DynamoDB table partition key attribute name."
  type        = string
  default     = "PK"
}

variable "dynamodb_range_key" {
  description = "DynamoDB table sort key attribute name (leave empty to omit)."
  type        = string
  default     = "SK"
}

# ---------------------------------------------------------------------------
# CloudTrail
# ---------------------------------------------------------------------------

variable "cloudtrail_log_retention_days" {
  description = "CloudWatch log retention for CloudTrail delivery (days)."
  type        = number
  default     = 90
}
