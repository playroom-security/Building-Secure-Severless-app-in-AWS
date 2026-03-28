output "trail_arn" {
  description = "CloudTrail trail ARN."
  value       = aws_cloudtrail.this.arn
}

output "trail_name" {
  description = "CloudTrail trail name."
  value       = aws_cloudtrail.this.name
}

output "log_bucket_name" {
  description = "S3 bucket name for CloudTrail logs."
  value       = aws_s3_bucket.trail_logs.id
}

output "log_bucket_arn" {
  description = "S3 bucket ARN for CloudTrail logs."
  value       = aws_s3_bucket.trail_logs.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group for CloudTrail delivery."
  value       = aws_cloudwatch_log_group.trail.name
}
