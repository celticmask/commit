resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.namespace
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_iam_role" "this" {
  name               = "${module.eks.cluster_name}-sa-${local.service_name}"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${kubernetes_namespace.ns.metadata[0].name}:${local.service_name}"
      ]
    }
  }
}

resource "aws_iam_policy" "s3" {
  name        = "${module.eks.cluster_name}-sa-${local.service_name}"
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.this.name
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.service_name
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
  }
}

resource "kubernetes_secret" "this" {
  metadata {
    generate_name = "${kubernetes_service_account.this.metadata.0.name}-token-"
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.this.metadata.0.name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true    
}

resource "kubernetes_cron_job_v1" "this" {
  metadata {
    name      = "commit"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0 * * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            service_account_name = kubernetes_service_account.this.metadata[0].name
            container {
              name    = "commit"
              image   = aws_ecr_repository.this.repository_url
              command = ["python", "main.py", "--url=${var.server_url}", "--bucket=${aws_s3_bucket.this.id}"]
            }
          }
        }
      }
    }
  }
}
