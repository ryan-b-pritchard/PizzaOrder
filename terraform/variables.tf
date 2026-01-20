
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}


variable "oidc_provider_url" {
  description = "OIDC provider URL (e.g. https://token.actions.githubusercontent.com)"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "oidc_thumbprint" {
  description = "Thumbprint for the OIDC provider TLS certificate. For GitHub Actions common thumbprint: 6938FD4D98BAB03FAADB97B34396831E3780AEA1"
  type        = string
  default     = "6938FD4D98BAB03FAADB97B34396831E3780AEA1"
}

variable "allowed_audiences" {
  description = "List of allowed audiences (aud claim) for tokens. Usually sts.amazonaws.com"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "allowed_subjects" {
  description = "List of allowed subject patterns (sub claim). For GitHub Actions use patterns like 'repo:owner/repo:ref:refs/heads/*' or 'repo:owner/repo:ref:refs/pull/*/merge'"
  type        = list(string)
  default     = [
    "repo:ryan-b-pritchard/PizzaOrder:ref:refs/heads/*",
    "repo:ryan-b-pritchard/PizzaOrder:ref:refs/pull/*/merge",
  ]
}

variable "role_name" {
  description = "Name for the IAM role created for CI"
  type        = string
  default     = "ci-oidc-role"
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs the CI role should be allowed to access (leave empty for none)"
  type        = list(string)
  default     = []
}

variable "ecr_repo_arns" {
  description = "List of ECR repository ARNs the CI role should be allowed to push/pull (leave empty for none)"
  type        = list(string)
  default     = []
}

variable "ecs_cluster_arns" {
  description = "List of ECS cluster ARNs the CI role may interact with (leave empty for none)"
  type        = list(string)
  default     = []
}

variable "ecs_service_arns" {
  description = "List of ECS service ARNs the CI role may update (leave empty for none)"
  type        = list(string)
  default     = []
}

variable "task_execution_role_arn" {
  description = "Task execution role ARN that CI is allowed to pass to ECS tasks (leave empty for none)"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "ARN of an existing OIDC provider (pre-provisioned). If empty, Terraform will not manage the provider."
  type        = string
  default     = "arn:aws:iam::279378876166:oidc-provider/token.actions.githubusercontent.com"
}

variable "existing_policy_arn" {
  description = "ARN of an existing IAM managed policy to attach to the CI role (leave empty to manage policy via Terraform)"
  type        = string
  default     = ""
}
