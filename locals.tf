# ---------------------------------------------------------------------------
# Shared locals — naming conventions, common tags, derived values used
# consistently across all modules.
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.app_name}-${var.environment}"

  common_tags = {
    Project     = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Convenience: full AWS partition ARN prefix (respects GovCloud / CN regions)
  aws_partition = data.aws_partition.current.partition
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}
