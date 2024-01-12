locals {
  account_id  = data.aws_caller_identity.current.account_id
  name_prefix = var.name_prefix
  tags = {
    team     = "devops"
    solution = "eks"
  }
  cluster_name = var.name_prefix

  service_name = "commit"
  namespace    = "development"
}
