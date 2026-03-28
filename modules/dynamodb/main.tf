resource "aws_dynamodb_table" "this" {
  name         = "${var.name_prefix}-table"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  # Sort key is optional
  dynamic "attribute" {
    for_each = var.range_key != "" ? [var.range_key] : []
    content {
      name = attribute.value
      type = "S"
    }
  }

  range_key = var.range_key != "" ? var.range_key : null

  attribute {
    name = var.hash_key
    type = "S"
  }

  # Encryption at rest using AWS-managed key (free, always-on alternative to CMK)
  server_side_encryption {
    enabled = true
  }

  # Point-In-Time Recovery
  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  # TTL
  dynamic "ttl" {
    for_each = var.ttl_attribute != "" ? [var.ttl_attribute] : []
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }

  tags = var.tags
}
