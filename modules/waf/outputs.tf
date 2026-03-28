output "web_acl_arn" {
  description = "WAFv2 Web ACL ARN."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "WAFv2 Web ACL ID."
  value       = aws_wafv2_web_acl.this.id
}

output "waf_log_group_name" {
  description = "CloudWatch log group name for WAF logs."
  value       = aws_cloudwatch_log_group.waf.name
}
