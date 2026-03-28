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

  # -----------------------------------------------------------------------
  # Remote State Backend
  # Uncomment and configure before running in CI or team environments.
  # Each environment (dev/prod) should use a unique key.
  # -----------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "YOUR-TERRAFORM-STATE-BUCKET"
  #   key            = "serverless-app/ENV/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "YOUR-TERRAFORM-LOCK-TABLE"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
