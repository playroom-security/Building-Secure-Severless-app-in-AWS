variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "domain_prefix" {
  description = "Cognito hosted-UI domain prefix (globally unique, lowercase alphanumeric/hyphens)."
  type        = string
}

variable "callback_urls" {
  description = "Allowed OAuth callback URLs."
  type        = list(string)
  default     = ["https://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "Allowed OAuth sign-out URLs."
  type        = list(string)
  default     = ["https://localhost:3000/logout"]
}

variable "access_token_validity_hours" {
  description = "Access token validity in hours (1-24)."
  type        = number
  default     = 1
}

variable "id_token_validity_hours" {
  description = "ID token validity in hours (1-24)."
  type        = number
  default     = 1
}

variable "refresh_token_validity_days" {
  description = "Refresh token validity in days."
  type        = number
  default     = 30
}

variable "password_minimum_length" {
  description = "Minimum user password length."
  type        = number
  default     = 12
}

variable "tags" {
  description = "Tags to apply to Cognito resources."
  type        = map(string)
  default     = {}
}
