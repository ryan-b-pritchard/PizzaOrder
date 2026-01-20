provider "aws" {
  region = var.aws_region
}

locals {
  issuer_host = replace(var.oidc_provider_url, "https://", "")
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "${local.issuer_host}:sub"
      values   = var.allowed_subjects
    }
  }
}

resource "aws_iam_role" "ci_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

locals {
  s3_bucket_arns  = var.s3_bucket_arns
  s3_object_arns  = [for b in local.s3_bucket_arns : "${b}/*"]
  ecr_repo_arns = var.ecr_repo_arns
  ecs_cluster_arns = var.ecs_cluster_arns
  ecs_service_arns = var.ecs_service_arns
  task_execution_role_arn = var.task_execution_role_arn

  create_policy = length(local.s3_bucket_arns) > 0 || length(local.ecr_repo_arns) > 0 || length(local.ecs_cluster_arns) > 0 || length(local.ecs_service_arns) > 0 || length(trimspace(local.task_execution_role_arn)) > 0
}

# Create a scoped S3 policy only when bucket ARNs are provided. Avoids wildcard resources.
locals {
  _s3_statements = length(local.s3_bucket_arns) > 0 ? [
    {
      Effect = "Allow"
      Action = ["s3:ListBucket"]
      Resource = local.s3_bucket_arns
    },
    {
      Effect = "Allow"
      Action = ["s3:GetObject","s3:PutObject","s3:DeleteObject"]
      Resource = local.s3_object_arns
    }
  ] : []

  _ecr_statements = length(local.ecr_repo_arns) > 0 ? [
    {
      # ECR GetAuthorizationToken is account-level and requires Resource = "*"
      Effect = "Allow"
      Action = ["ecr:GetAuthorizationToken"]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:DescribeRepositories",
        "ecr:GetRepositoryPolicy"
      ]
      Resource = local.ecr_repo_arns
    }
  ] : []

  _ecs_statements = (length(local.ecs_cluster_arns) > 0 || length(local.ecs_service_arns) > 0) ? [
    {
      Effect = "Allow"
      Action = [
        "ecs:DescribeClusters",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:ListTasks",
        "ecs:DescribeTasks",
        "ecs:RegisterTaskDefinition"
      ]
      Resource = concat(local.ecs_cluster_arns, local.ecs_service_arns)
    }
  ] : []

  _passrole_statement = length(trimspace(local.task_execution_role_arn)) > 0 ? [
    {
      Effect = "Allow"
      Action = ["iam:PassRole"]
      Resource = [local.task_execution_role_arn]
      Condition = {
        StringEquals = {
          "iam:PassedToService" = "ecs-tasks.amazonaws.com"
        }
      }
    }
  ] : []

  policy_statements = concat(local._s3_statements, local._ecr_statements, local._ecs_statements, local._passrole_statement)
}

resource "aws_iam_policy" "ci_policy" {
  count = (local.create_policy && length(trimspace(var.existing_policy_arn)) == 0) ? 1 : 0

  name = "ci-policy-${var.role_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = local.policy_statements
  })
}

# Attach either an existing managed policy (provided via var.existing_policy_arn)
# or the policy created above. If neither is provided, no managed policy is attached.
resource "aws_iam_role_policy_attachment" "attach" {
  count = (length(trimspace(var.existing_policy_arn)) > 0 || local.create_policy) ? 1 : 0

  role = aws_iam_role.ci_role.name
  policy_arn = length(trimspace(var.existing_policy_arn)) > 0 ? var.existing_policy_arn : aws_iam_policy.ci_policy[0].arn
}
