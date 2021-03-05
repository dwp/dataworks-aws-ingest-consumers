locals {
  batch_corporate_storage_coalescer_image            = "${local.account.management}.${data.terraform_remote_state.ingest.outputs.vpc.vpc.ecr_dkr_domain_name}/dataworks-corporate-storage-coalescence:${var.image_version.corporate-storage-coalescer}"
  batch_corporate_storage_coalescer_application_name = "corporate-storage-coalescer"
  config_prefix                      = "component/rbac"
  config_filename                    = "data_classification.csv"
  data_s3_prefix                     = "data/uc/uc.db"
}

data "aws_iam_policy_document" "batch_assume_policy" {
  statement {
    sid    = "BatchAssumeRolePolicy"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]

      type = "Service"
    }
  }
}

resource "aws_iam_role" "batch_corporate_storage_coalescer" {
  name               = "batch_corporate_storage_coalescer"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_policy.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "batch_corporate_storage_coalescer_config_bucket" {
  statement {
    sid    = "AllowS3GetConfigObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${local.config_prefix}/*",
    ]
  }

  statement {
    sid    = "AllowDecryptConfigBucketObjects"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.config_bucket_cmk.arn,
    ]
  }
}

data "aws_iam_policy_document" "batch_corporate_storage_coalescer_s3" {
  statement {
    sid    = "AllowS3ReadWrite"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "${local.internal_compute_manifest_bucket.arn}/*",
      "${local.ingest_corporate_storage_bucket.arn}/*",
    ]
  }

  statement {
    sid    = "AllowS3ListObjects"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      local.internal_compute_manifest_bucket.arn,
      local.ingest_corporate_storage_bucket.arn,
    ]
  }

  statement {
    sid    = "AllowKMSEncryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = [
      local.internal_compute_manifest_bucket_cmk.arn,
      local.ingest_input_bucket_cmk_arn
    ]
  }
}

resource "aws_iam_policy" "batch_corporate_storage_coalescer_config" {
  name   = "batch_corporate_storage_coalescer_config"
  policy = data.aws_iam_policy_document.batch_corporate_storage_coalescer_config_bucket.json
}

resource "aws_iam_policy" "batch_corporate_storage_coalescer_s3" {
  name   = "batch_corporate_storage_coalescer_s3"
  policy = data.aws_iam_policy_document.batch_corporate_storage_coalescer_s3.json
}

resource "aws_iam_role_policy_attachment" "batch_corporate_storage_coalescer_config" {
  role       = aws_iam_role.batch_corporate_storage_coalescer.name
  policy_arn = aws_iam_policy.batch_corporate_storage_coalescer_config.arn
}

resource "aws_iam_role_policy_attachment" "batch_corporate_storage_coalescer_s3" {
  role       = aws_iam_role.batch_corporate_storage_coalescer.name
  policy_arn = aws_iam_policy.batch_corporate_storage_coalescer_s3.arn
}

resource "aws_batch_job_queue" "batch_corporate_storage_coalescer" {
  //  TODO: Move compute environment to fargate once Terraform supports it.
  compute_environments = [aws_batch_compute_environment.corporate_storage_coalescer.arn]
  name                 = "batch_corporate_storage_coalescer"
  priority             = 10
  state                = "ENABLED"
}

resource "aws_batch_job_definition" "batch_corporate_storage_coalescer_storage" {
  name = "batch_corporate_storage_coalescer_job_storage"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
  {
      "command": [
            "-b", "Ref::s3-bucket-id",
            "-p", "Ref::s3-prefix",
            "-n", "Ref::partition",
            "-t", "Ref::threads",
            "-f", "Ref::max-files",
            "-s", "Ref::max-size",
            "-m"
          ],
      "image": "${local.batch_corporate_storage_coalescer_image}",
      "jobRoleArn" : "${aws_iam_role.batch_corporate_storage_coalescer.arn}",
      "memory": 32768,
      "vcpus": 2,
      "environment": [
          {"name": "LOG_LEVEL", "value": "INFO"},
          {"name": "AWS_DEFAULT_REGION", "value": "eu-west-2"},
          {"name": "DATA_BUCKET", "value": "${data.terraform_remote_state.common.outputs.published_bucket.id}"},
          {"name": "ENVIRONMENT", "value": "${local.environment}"},
          {"name": "APPLICATION", "value": "${local.batch_corporate_storage_coalescer_application_name}"}
      ],
      "ulimits": [
        {
          "hardLimit": 32768,
          "name": "nofile",
          "softLimit": 32768
        }
      ]
  }
  CONTAINER_PROPERTIES
}

resource "aws_batch_job_definition" "batch_corporate_storage_coalescer_manifests" {
  name = "batch_corporate_storage_coalescer_job_manifests"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
  {
      "command": [
            "-b", "Ref::s3-bucket-id",
            "-p", "Ref::s3-prefix",
            "-n", "Ref::partition",
            "-t", "Ref::threads",
            "-f", "Ref::max-files",
            "-s", "Ref::max-size",
            "-m",
            "-a"
          ],
      "image": "${local.batch_corporate_storage_coalescer_image}",
      "jobRoleArn" : "${aws_iam_role.batch_corporate_storage_coalescer.arn}",
      "memory": 32768,
      "vcpus": 2,
      "environment": [
          {"name": "LOG_LEVEL", "value": "INFO"},
          {"name": "AWS_DEFAULT_REGION", "value": "eu-west-2"},
          {"name": "DATA_BUCKET", "value": "${data.terraform_remote_state.common.outputs.published_bucket.id}"},
          {"name": "ENVIRONMENT", "value": "${local.environment}"},
          {"name": "APPLICATION", "value": "${local.batch_corporate_storage_coalescer_application_name}"}
      ],
      "ulimits": [
        {
          "hardLimit": 32768,
          "name": "nofile",
          "softLimit": 32768
        }
      ]
  }
  CONTAINER_PROPERTIES
}
