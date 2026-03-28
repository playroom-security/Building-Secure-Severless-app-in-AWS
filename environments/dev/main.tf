terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # Uncomment and configure for remote state:
  # backend "s3" {
  #   bucket         = "YOUR-TERRAFORM-STATE-BUCKET"
  #   key            = "serverless-app/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "YOUR-TERRAFORM-LOCK-TABLE"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.app_name
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name_prefix = "${var.app_name}-dev"
  tags = {
    Project     = var.app_name
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ---- DynamoDB ----------------------------------------------------------------
module "dynamodb" {
  source      = "../../modules/dynamodb"
  name_prefix = local.name_prefix
  hash_key    = var.dynamodb_hash_key
  range_key   = var.dynamodb_range_key
  enable_pitr = true
  tags        = local.tags
}

# ---- Lambda ------------------------------------------------------------------
module "lambda" {
  source               = "../../modules/lambda"
  name_prefix          = local.name_prefix
  source_dir           = "${path.root}/../../src/lambda"
  handler              = var.lambda_handler
  runtime              = var.lambda_runtime
  memory_mb            = var.lambda_memory_mb
  timeout_seconds      = var.lambda_timeout_seconds
  reserved_concurrency = 10 # conservative dev cap

  environment_variables = {
    TABLE_NAME  = module.dynamodb.table_name
    ENVIRONMENT = "dev"
    LOG_LEVEL   = "DEBUG"
  }

  dynamodb_table_arn = module.dynamodb.table_arn
  log_retention_days = 14
  tags               = local.tags
}

# ---- Cognito -----------------------------------------------------------------
module "cognito" {
  source        = "../../modules/cognito"
  name_prefix   = local.name_prefix
  domain_prefix = var.cognito_domain_prefix
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls
  tags          = local.tags
}

# ---- HTTP API Gateway --------------------------------------------------------
module "api" {
  source               = "../../modules/api"
  name_prefix          = local.name_prefix
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name

  cognito_user_pool_endpoint  = module.cognito.user_pool_endpoint
  cognito_user_pool_client_id = module.cognito.user_pool_client_id

  cors_allow_origins     = ["*"] # Relax for dev; tighten in prod
  throttling_burst_limit = 200
  throttling_rate_limit  = 500
  log_retention_days     = 14
  tags                   = local.tags
}

# ---- WAF ---------------------------------------------------------------------
module "waf" {
  source                 = "../../modules/waf"
  name_prefix            = local.name_prefix
  api_stage_arn          = module.api.stage_arn
  waf_log_retention_days = 30
  tags                   = local.tags
}

# ---- CloudTrail --------------------------------------------------------------
module "cloudtrail" {
  source                 = "../../modules/cloudtrail"
  name_prefix            = local.name_prefix
  aws_account_id         = var.aws_account_id
  aws_region             = var.aws_region
  log_retention_days     = 30
  s3_log_expiration_days = 90
  tags                   = local.tags
}
