variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "source_dir" {
  description = "Path to the Lambda source directory to be zipped."
  type        = string
}

variable "handler" {
  description = "Lambda handler (file.function)."
  type        = string
  default     = "handler.handler"
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "memory_mb" {
  description = "Memory in MB."
  type        = number
  default     = 256
}

variable "timeout_seconds" {
  description = "Execution timeout in seconds."
  type        = number
  default     = 29
}

variable "environment_variables" {
  description = "Map of environment variables to set on the function."
  type        = map(string)
  default     = {}
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table to allow read/write access from this function."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 30
}

variable "reserved_concurrency" {
  description = "Reserved concurrency limit. -1 means unreserved."
  type        = number
  default     = -1
}

variable "tags" {
  description = "Tags to apply to Lambda resources."
  type        = map(string)
  default     = {}
}
