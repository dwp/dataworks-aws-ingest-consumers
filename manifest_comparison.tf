resource "aws_glue_catalog_database" "manifest_etl" {
  name        = "manifestetl"
  description = "Database for the Manifest comparision ETL"
}

# Some of these permissions may not be required, this is a copy of the built-in AWS
# IAM Policy "AWSGlueServiceRole" with some things obviously not needed removed
data "aws_iam_policy_document" "manifest_etl" {
  statement {
    effect = "Allow"

    actions = [
      "glue:*",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeRouteTables",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcAttribute",
      "iam:ListRolePolicies",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:CreateBucket",
    ]

    resources = ["arn:aws:s3:::aws-glue-*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::aws-glue-*/*",
      "arn:aws:s3:::*/*aws-glue-*/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::crawler-public*",
      "arn:aws:s3:::aws-glue-*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:/aws-glue/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]

    resources = [
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:instance/*",
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"

      values = [
        "aws-glue-service-resource",
      ]
    }
  }
}

data "aws_iam_policy_document" "manifest_etl_s3" {
  statement {
    sid    = "ManifestETLListBucket"
    effect = "Allow"

    actions = [
      "s3:GetBucket*",
      "s3:ListBucket*",
    ]

    resources = [
      data.terraform_remote_state.internal_compute.outputs.manifest_bucket.arn,
      data.terraform_remote_state.common.outputs.config_bucket.arn,
    ]
  }

  statement {
    sid    = "ManifestETLWriteBucket"
    effect = "Allow"

    actions = [
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:GetBucketACL",
    ]

    resources = [
      "${data.terraform_remote_state.internal_compute.outputs.manifest_bucket.arn}/${data.terraform_remote_state.ingest.outputs.ingest_emr_s3_prefixes.base_root_prefix}/manifest/*",
      "${data.terraform_remote_state.internal_compute.outputs.manifest_bucket.arn}/${data.terraform_remote_state.ingest.outputs.ingest_emr_s3_prefixes.base_root_prefix}/manifest/",
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/glue/scripts/*",
    ]
  }

  statement {
    sid    = "ManifestETLKMSEncrypt"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.internal_compute.outputs.manifest_bucket_cmk.arn,
      data.terraform_remote_state.common.outputs.config_bucket_cmk.arn,
    ]
  }
}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "manifest_etl" {
  name               = "AWSGlueServiceRole_manifest_etl"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "manifest-etl"
    },
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_policy" "manifest_etl" {
  name        = "manifest_etl"
  description = "Allows AWS Glue access to required AWS Resources"
  policy      = data.aws_iam_policy_document.manifest_etl.json
}

resource "aws_iam_policy" "manifest_etl_s3" {
  name        = "manifest_etl_s3"
  description = "Allows write access to the Manifest ETL bucket"
  policy      = data.aws_iam_policy_document.manifest_etl_s3.json
}

resource "aws_iam_role_policy_attachment" "manifest_etl" {
  role       = aws_iam_role.manifest_etl.name
  policy_arn = aws_iam_policy.manifest_etl.arn
}

resource "aws_iam_role_policy_attachment" "manifest_etl_s3" {
  role       = aws_iam_role.manifest_etl.name
  policy_arn = aws_iam_policy.manifest_etl_s3.arn
}

resource "aws_s3_bucket_object" "manifest_etl_script_combined" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "/glue/scripts/${local.environment}_manifest_etl_combined.py"
  content = templatefile("files/manifest_comparison/aws_glue_script_combined.py.tpl",
    {
      database_name                            = aws_glue_catalog_database.manifest_etl.name,
      table_name_missing_imports_parquet       = local.manifest_comparison_missing_imports_parquet_table_name,
      table_name_missing_exports_parquet       = local.manifest_comparison_missing_exports_parquet_table_name,
      table_name_mismatched_timestamps_parquet = local.manifest_comparison_mismatched_timestamps_parquet_table_name,
      table_name_counts_parquet                = local.manifest_comparison_counts_parquet_table_name,
      manifest_bucket_id                       = data.terraform_remote_state.internal_compute.outputs.manifest_bucket.id
  })
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "manifest-etl-script-combined"
    },
  )
}

resource "aws_glue_job" "manifest_etl_combined" {
  name              = "manifest_etl_combined"
  role_arn          = aws_iam_role.manifest_etl.arn
  worker_type       = "G.2X"
  glue_version      = "2.0"
  number_of_workers = "149"
  notification_property {
    notify_delay_after = 1
  }
  tags = merge(
    local.common_tags,
    {
      glue_script_hash = filemd5("files/manifest_comparison/aws_glue_script_combined.py.tpl")
    },
  )

  command {
    script_location = "s3://${aws_s3_bucket_object.manifest_etl_script_combined.bucket}${aws_s3_bucket_object.manifest_etl_script_combined.key}"
  }
}

output "manifest_etl" {
  value = {
    job_name_combined                        = aws_glue_job.manifest_etl_combined.name
    database_name                            = aws_glue_catalog_database.manifest_etl.name
    table_name_import_csv                    = local.manifest_comparison_import_csv_table_name
    table_name_export_csv                    = local.manifest_comparison_export_csv_table_name
    table_name_missing_imports_parquet       = local.manifest_comparison_missing_imports_parquet_table_name
    table_name_missing_exports_parquet       = local.manifest_comparison_missing_exports_parquet_table_name
    table_name_counts_parquet                = local.manifest_comparison_counts_parquet_table_name
    table_name_mismatched_timestamps_parquet = local.manifest_comparison_mismatched_timestamps_parquet_table_name
  }
}
