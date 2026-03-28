variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "api_stage_arn" {
  description = "ARN of the API Gateway stage to associate this web ACL with."
  type        = string
}

variable "waf_log_retention_days" {
  description = "CloudWatch log retention for WAF logs in days."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to WAF resources."
  type        = map(string)
  default     = {}
}
