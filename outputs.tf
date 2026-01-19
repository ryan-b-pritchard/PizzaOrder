output "oidc_provider_arn" {
  description = "ARN of the created OIDC provider"
  value       = aws_iam_openid_connect_provider.gitlab.arn
}

output "ci_role_arn" {
  description = "ARN of the IAM role for GitLab CI to assume"
  value       = aws_iam_role.gitlab_ci_role.arn
}
