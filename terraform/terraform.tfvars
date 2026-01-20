s3_bucket_arns = [
  "arn:aws:s3:::pizzaorder-tfstate"
]

ecr_repo_arns = [
  "arn:aws:ecr:us-east-1:279378876166:repository/pizzaorder"
]

ecs_cluster_arns = [
  "arn:aws:ecs:us-east-1:279378876166:cluster/pizzaorder-cluster"
]

ecs_service_arns = [
  "arn:aws:ecs:us-east-1:279378876166:service/pizzaorder-cluster/pizzaorder-service"
]

task_execution_role_arn = "arn:aws:iam::279378876166:role/ecsTaskExecutionRole"

existing_policy_arn = "arn:aws:iam::279378876166:policy/ci-policy-ci-oidc-role"

oidc_provider_arn = "arn:aws:iam::279378876166:oidc-provider/token.actions.githubusercontent.com"
