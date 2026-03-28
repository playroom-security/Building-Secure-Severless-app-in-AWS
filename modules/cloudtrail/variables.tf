variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID used to scope the S3 bucket policy."
  type        = string
}

variable "aws_region" {
  description = "Primary AWS region."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days for CloudTrail delivery."
  type        = number
  default     = 90
}

variable "s3_log_expiration_days" {
  description = "Number of days before CloudTrail logs are expired from S3."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags to apply to CloudTrail resources."
  type        = map(string)
  default     = {}
}
