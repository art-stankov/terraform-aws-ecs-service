data "aws_partition" "current" {}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_execution_role_policy_doc" {
  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:${local.partition}:logs:::log-group:${local.name}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_elb_service_account" "main" {}

### Access Logs Bucket Policy
data "aws_iam_policy_document" "access_logs_bucket" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${local.bucket}/*"]

    principals {
      identifiers = [local.service_account]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${local.bucket}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["arn:${local.partition}:s3:::${local.bucket}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
