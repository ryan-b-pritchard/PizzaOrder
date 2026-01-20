output "oidc_provider_arn" {
  description = "ARN of the created OIDC provider"
  value       = var.oidc_provider_arn
}

output "ci_role_arn" {
  description = "ARN of the IAM role for CI (GitHub Actions) to assume"
  value       = aws_iam_role.ci_role.arn
}
