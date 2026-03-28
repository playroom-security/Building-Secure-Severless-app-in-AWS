# Building a Secure Serverless App in AWS

A production-ready, secure-by-default serverless application built on AWS, fully managed with Terraform.

---

## Architecture

```
                          ┌─────────────────────────────────────-┐
  Browser / Client        │             AWS Cloud                │
  ─────────────────       │                                      │
                          │  ┌───────────┐                       │
  1. Login via            │  │  Cognito  │  Hosted UI            │
     Hosted UI  ─────────►│  │ User Pool │  JWT tokens           │
                          │  └─────┬─────┘                       │
  2. Call API with JWT    │        │ JWT authorizer              │
     ─────────────────────┼──►┌────▼──────┐                      │
                          │   │    WAF    │  Managed rules       │
                          │   │  Web ACL  │  (OWASP/SQLi/IP rep) │
                          │   └────┬──────┘                      │
                          │        │ filtered traffic            │
                          │   ┌────▼──────────┐                  │
                          │   │  API Gateway  │  HTTP API        │
                          │   │  (HTTP API)   │  JWT authorizer  │
                          │   └────┬──────────┘                  │
                          │        │ AWS_PROXY                   │
                          │   ┌────▼──────┐                      │
                          │   │  Lambda   │  Python 3.12         │
                          │   │ Function  │  Least-privilege IAM │
                          │   └────┬──────┘                      │
                          │        │ GetItem / PutItem           │
                          │   ┌────▼──────┐                      │
                          │   │ DynamoDB  │  Encrypted, PITR     │
                          │   │   Table   │  TTL, SSE            │
                          │   └───────────┘                      │
                          │                                      │
                          │  ┌───────────────┐                   │
                          │  │  CloudTrail   │  Multi-region     │
                          │  │  (all events) │  S3 + CW Logs     │
                          │  └───────────────┘                   │
                          └─────────────────────────────────────-┘
```

### Components

| Service                | Role                              | Security controls                                                                                      |
| ---------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------ |
| **Amazon Cognito**     | User authentication, JWT issuance | Strong password policy, MFA optional, user-existence-error prevention, short-lived access tokens       |
| **AWS WAF**            | Edge protection                   | AWS Managed Rules: CommonRuleSet, KnownBadInputs, AmazonIpReputationList, AnonymousIpList, SQLiRuleSet |
| **API Gateway (HTTP)** | API front door                    | Cognito JWT authorizer on every route, access logging, throttle limits, CORS                           |
| **AWS Lambda**         | Business logic compute            | Least-privilege IAM (table-scoped), reserved concurrency cap                                           |
| **Amazon DynamoDB**    | Persistent storage                | SSE at rest, PITR, TTL                                                                                 |
| **AWS CloudTrail**     | Audit & compliance                | Multi-region trail, log file validation, S3 encryption, CloudWatch delivery                            |

---

## Repository Layout

```
.
├── modules/
│   ├── cognito/          # Cognito user pool + hosted UI + app client
│   ├── api/              # HTTP API Gateway + JWT authorizer + routes
│   ├── waf/              # WAFv2 web ACL + managed rule groups + logging
│   ├── lambda/           # Lambda function + IAM role + CW log group
│   ├── dynamodb/         # DynamoDB table + SSE + PITR
│   └── cloudtrail/       # CloudTrail + S3 log bucket + CW delivery
├── environments/
│   ├── dev/              # Dev composition (all modules wired together)
│   └── prod/             # Prod composition
├── src/
│   └── lambda/
│       └── handler.py    # Python Lambda handler
├── providers.tf          # Root provider + backend placeholder
├── variables.tf          # Root variable declarations
├── locals.tf             # Shared naming/tagging locals
└── outputs.tf            # Root-level outputs
```

---

## Prerequisites

| Tool                                                                           | Minimum version           |
| ------------------------------------------------------------------------------ | ------------------------- |
| [Terraform](https://developer.hashicorp.com/terraform/install)                 | 1.7.0                     |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | v2                        |
| Python                                                                         | 3.12 (for Lambda runtime) |
| An AWS account with sufficient IAM permissions                                 | —                         |

---

## Quick-Start Deployment

### 1. Configure AWS credentials

```bash
aws configure          # or use AWS_PROFILE / AWS_ACCESS_KEY_ID / IAM role
```

### 2. Configure the environment

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set aws_account_id and cognito_domain_prefix
```

### 3. Initialise and apply

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Note the outputs

```bash
terraform output cognito_hosted_ui_url   # → open in browser to sign up / log in
terraform output api_endpoint            # → base URL for API calls
terraform output dynamodb_table_name
```

---

## Authentication Flow

1. Open the `cognito_hosted_ui_url` in a browser.
2. Sign up with an email address (verification code sent automatically).
3. After confirming, sign in to receive an `id_token` and `access_token`.
4. Pass the `access_token` as a Bearer token in the `Authorization` header of every API call.

```bash
TOKEN="<paste_access_token_here>"
API="<api_endpoint>"

curl -H "Authorization: Bearer $TOKEN" "$API/items"
curl -H "Authorization: Bearer $TOKEN" -X POST "$API/items" \
     -H "Content-Type: application/json" \
     -d '{"name":"my first item"}'
```

---

## API Endpoints

All routes require a valid Cognito JWT (`Authorization: Bearer <token>`).

| Method   | Path          | Description                               |
| -------- | ------------- | ----------------------------------------- |
| `GET`    | `/items`      | List all items for the authenticated user |
| `POST`   | `/items`      | Create a new item                         |
| `GET`    | `/items/{id}` | Retrieve a single item by ID              |
| `DELETE` | `/items/{id}` | Delete an item                            |

---

## Deploying to Prod

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Update cognito_callback_urls, cognito_logout_urls, api_cors_allow_origins
# to match your real app domain — do NOT use wildcard origins in prod
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Remote State (Recommended)

Before running in a shared/CI environment, configure an S3 backend to avoid state drift.

1. Create an S3 bucket and a DynamoDB table for locking (e.g. via the AWS console or a separate bootstrap Terraform config).
2. Uncomment and fill in the `backend "s3"` block in `environments/dev/main.tf` (and `prod/main.tf`).
3. Run `terraform init -migrate-state` to push local state to S3.

---

## Security Notes

- **Secrets**: `terraform.tfvars` is gitignored. Never commit AWS account IDs, client IDs, or tokens.
- **WAF**: The WAF web ACL runs in `REGIONAL` scope, associated with the API Gateway `$default` stage. The `Authorization` header is redacted from WAF logs.
- **Cognito MFA**: MFA is set to `OPTIONAL` by default. Change to `"ON"` in `modules/cognito/main.tf` for higher-assurance environments.
- **CORS**: Dev uses `allow_origins = ["*"]`. Prod requires explicit allowed origins via `api_cors_allow_origins`.
- **Lambda concurrency**: Dev caps at 10, prod at 100. Adjust to match your workload before scaling up.
- **DynamoDB encryption**: AWS-managed keys (SSE) are on by default. Switch to a CMK (`aws_kms_key`) for stricter key control.

---

## Smoke Test Checklist

After deploying dev, verify:

- [ ] Cognito hosted UI loads and allows sign-up + sign-in.
- [ ] API returns `401` when called without a token.
- [ ] API returns `200` for `GET /items` with a valid JWT.
- [ ] `POST /items` creates a record visible in the DynamoDB table.
- [ ] CloudTrail events appear in the S3 log bucket within ~15 minutes.
- [ ] WAF CloudWatch metrics appear in the AWS console under `aws-waf-logs-*`.

---

## Teardown

```bash
cd environments/dev
terraform destroy
```

> **Note:** The CloudTrail S3 bucket has `force_destroy = false`. Empty it manually before destroy, or change the flag to `true` in `modules/cloudtrail/main.tf` for non-production environments.
