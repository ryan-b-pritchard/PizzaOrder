
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
  default     = "gitlab-ci-oidc-role"
}
