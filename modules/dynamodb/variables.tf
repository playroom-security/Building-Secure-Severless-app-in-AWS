variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "hash_key" {
  description = "Partition key attribute name."
  type        = string
  default     = "PK"
}

variable "range_key" {
  description = "Sort key attribute name. Set to empty string to omit."
  type        = string
  default     = "SK"
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "enable_pitr" {
  description = "Enable Point-In-Time Recovery."
  type        = bool
  default     = true
}

variable "ttl_attribute" {
  description = "Attribute name for TTL. Set to empty string to disable."
  type        = string
  default     = "ExpiresAt"
}

variable "tags" {
  description = "Tags to apply to the table."
  type        = map(string)
  default     = {}
}
