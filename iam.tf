provider "aws" {
  region = var.aws_region
}

locals {
  issuer_host = replace(var.oidc_provider_url, "https://", "")
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = var.oidc_provider_url
  client_id_list  = var.allowed_audiences
  thumbprint_list = var.oidc_thumbprint == "" ? [] : [var.oidc_thumbprint]
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "${local.issuer_host}:sub"
      values   = var.allowed_subjects
    }
  }
}

resource "aws_iam_role" "gitlab_ci_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "gitlab_ci_policy" {
  name = "gitlab-ci-policy-${var.role_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.gitlab_ci_role.name
  policy_arn = aws_iam_policy.gitlab_ci_policy.arn
}
