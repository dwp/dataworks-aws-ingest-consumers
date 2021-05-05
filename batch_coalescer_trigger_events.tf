resource "aws_cloudwatch_event_rule" "utc_00_30_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_30_Daily"
  description         = "30 minutes past midnight every day"
  schedule_expression = "cron(30 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_31_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_31_daily"
  description         = "31 minutes past midnight every day"
  schedule_expression = "cron(31 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_32_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_32_daily"
  description         = "32 minutes past midnight every day"
  schedule_expression = "cron(32 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_33_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_33_daily"
  description         = "33 minutes past midnight every day"
  schedule_expression = "cron(33 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_34_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_34_daily"
  description         = "34 minutes past midnight every day"
  schedule_expression = "cron(34 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_35_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_35_daily"
  description         = "35 minutes past midnight every day"
  schedule_expression = "cron(35 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_36_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_36_daily"
  description         = "36 minutes past midnight every day"
  schedule_expression = "cron(36 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_37_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_37_daily"
  description         = "37 minutes past midnight every day"
  schedule_expression = "cron(37 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "utc_00_38_daily" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_00_38_daily"
  description         = "38 minutes past midnight every day"
  schedule_expression = "cron(38 0 * * ? *)"
}

resource "aws_iam_role" "cloudwatch_events" {
  count = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name  = "cloudwatch_events"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "batch_submit_job_with_any_role" {
  count = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name  = "batch_submit_job_with_any_role"
  role  = aws_iam_role.cloudwatch_events[0].id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "batch:SubmitJob"
            ],
            "Resource": "*"
        }
    ]
}
DOC
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_equalities" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchStorageEqualities"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_30_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_equalities"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_equalities}",
        "partition": "-1",
        "threads": "1",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_equalities_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_equalities_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_audit" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchStorageAudit"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_30_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_audit"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_audit}",
        "partition": "-1",
        "threads": "0",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_main" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchStorageMain"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_30_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_main"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_ucfs}",
        "partition": "-1",
        "threads": "0",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_equalities" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchManifestEqualities"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_30_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_equalities"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.equality_prefix}",
        "partition": "-1",
        "threads": "1",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_equalities_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_equalities_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

#############################################################################################################################
# The below ones have to be done 5 at a time and use different rules due to AWS limitation of 5 targets per rule maximum
#############################################################################################################################

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_0_to_4" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_00_31_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.audit_prefix}",
        "partition": "${count.index}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_5_to_9" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index + 5}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_00_32_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index + 5}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.audit_prefix}",
        "partition": "${count.index + 5}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_10_to_14" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index + 10}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_00_33_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index + 10}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.audit_prefix}",
        "partition": "${count.index + 10}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_15_to_19" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index + 15}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_00_34_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index + 15}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.audit_prefix}",
        "partition": "${count.index + 15}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_0_to_4" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_35_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.main_prefix}",
        "partition": "${count.index}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_5_to_9" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index + 5}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_36_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index + 5}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.main_prefix}",
        "partition": "${count.index + 5}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_10_to_14" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index + 10}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_37_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index + 10}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.main_prefix}",
        "partition": "${count.index + 10}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_15_to_19" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index + 15}"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_00_38_daily[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index + 15}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.internal_compute_manifest_bucket.id}",
        "s3-prefix": "${local.ingest_manifest_write_locations.main_prefix}",
        "partition": "${count.index + 15}",
        "threads": "0",
        "date-to-add": "NOT_SET",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}
