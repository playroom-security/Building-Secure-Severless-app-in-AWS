locals {
  web_acl_name = "${var.name_prefix}-web-acl"
}

# ---- WAFv2 Web ACL (REGIONAL — for API Gateway) -----------------------------
resource "aws_wafv2_web_acl" "this" {
  name  = local.web_acl_name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # ---- AWS Managed Rule Groups ------------------------------------------------

  # Core rule set — protects against OWASP Top 10 (SQLi, XSS, etc.)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.web_acl_name}-common"
      sampled_requests_enabled   = true
    }
  }

  # Known bad inputs — blocks request patterns that exploit known vulnerabilities
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.web_acl_name}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # Amazon IP reputation list — blocks IPs identified as malicious
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.web_acl_name}-ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  # Anonymous IP list — blocks known VPNs, Tor exit nodes, botnets
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAnonymousIpList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.web_acl_name}-anon-ip"
      sampled_requests_enabled   = true
    }
  }

  # SQLi-specific rule set
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.web_acl_name}-sqli"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.web_acl_name
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# ---- Associate WAF Web ACL with API Gateway stage ---------------------------
resource "aws_wafv2_web_acl_association" "api_stage" {
  resource_arn = var.api_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# ---- WAF Logging: CloudWatch Logs -------------------------------------------
# WAF log group name MUST start with "aws-waf-logs-"
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.name_prefix}"
  retention_in_days = var.waf_log_retention_days
  tags              = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn

  # Redact the Authorization header from WAF logs to prevent token leakage
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}
