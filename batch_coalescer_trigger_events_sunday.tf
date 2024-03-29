resource "aws_cloudwatch_event_rule" "utc_08_30_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_30_sunday"
  description         = "30 minutes past 8am on sundays"
  schedule_expression = "cron(30 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_31_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_31_sunday"
  description         = "31 minutes past 8am on sundays"
  schedule_expression = "cron(31 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_32_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_32_sunday"
  description         = "32 minutes past 8am on sundays"
  schedule_expression = "cron(32 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_33_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_33_sunday"
  description         = "33 minutes past 8am on sundays"
  schedule_expression = "cron(33 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_34_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_34_sunday"
  description         = "34 minutes past 8am on sundays"
  schedule_expression = "cron(34 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_35_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_35_sunday"
  description         = "35 minutes past 8am on sundays"
  schedule_expression = "cron(35 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_36_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_36_sunday"
  description         = "36 minutes past 8am on sundays"
  schedule_expression = "cron(36 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_37_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_37_sunday"
  description         = "37 minutes past 8am on sundays"
  schedule_expression = "cron(37 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_38_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_38_sunday"
  description         = "38 minutes past 8am on sundays"
  schedule_expression = "cron(38 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_39_daily_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_39_daily_sunday"
  description         = "39 minutes past 8am on sundays"
  schedule_expression = "cron(39 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_40_daily_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_40_daily_sunday"
  description         = "40 minutes past 8am on sundays"
  schedule_expression = "cron(40 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_41_daily_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_41_daily_sunday"
  description         = "41 minutes past 8am on sundays"
  schedule_expression = "cron(41 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_rule" "utc_08_42_daily_sunday" {
  count               = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  name                = "utc_08_42_daily_sunday"
  description         = "42 minutes past 8am on sundays"
  schedule_expression = "cron(42 8 ? * SUN *)"
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_equalities_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchStorageEqualitiesSunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_30_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_equalities_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_audit_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchStorageAuditSunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_30_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_audit_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_equalities_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 1 : 0
  target_id = "RunCoalescerBatchManifestEqualitiesSunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_30_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_equalities_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_0_to_4_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_08_31_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_5_to_9_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index + 5}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_08_32_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index + 5}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_10_to_14_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index + 10}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_08_33_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index + 10}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_audit_per_partition_15_to_19_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestAuditPartition${count.index + 15}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running.arn
  rule      = aws_cloudwatch_event_rule.utc_08_34_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_audit_partition_${count.index + 15}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_0_to_4_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_35_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_5_to_9_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index + 5}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_36_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index + 5}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_10_to_14_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index + 10}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_37_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index + 10}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_manifest_main_per_partition_15_to_19_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchManifestMainPartition${count.index + 15}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_38_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_manifests.arn
    job_name       = "run_coalescer_batch_manifest_main_partition_${count.index + 15}_sunday"
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

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_main_per_partition_0_to_4_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchStorageMainPartition${count.index}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_39_daily_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_main_partition_${count.index}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_ucfs}",
        "partition": "${count.index}",
        "threads": "0",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_main_per_partition_5_to_9_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchStorageMainPartition${count.index + 5}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_40_daily_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_main_partition_${count.index + 5}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_ucfs}",
        "partition": "${count.index + 5}",
        "threads": "0",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_main_per_partition_10_to_14_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchStorageMainPartition${count.index + 10}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_41_daily_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_main_partition_${count.index + 10}"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_ucfs}",
        "partition": "${count.index + 10}",
        "threads": "0",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "run_coalescer_batch_storage_main_per_partition_15_to_19_sunday" {
  count     = local.batch_coalescer_scheduled_executions[local.environment] == true ? 5 : 0
  target_id = "RunCoalescerBatchStorageMainPartition${count.index + 15}Sunday"
  arn       = aws_batch_job_queue.batch_corporate_storage_coalescer.arn
  rule      = aws_cloudwatch_event_rule.utc_08_42_daily_sunday[0].name
  role_arn  = aws_iam_role.cloudwatch_events[0].arn

  batch_target {
    job_definition = aws_batch_job_definition.batch_corporate_storage_coalescer_storage.arn
    job_name       = "run_coalescer_batch_storage_main_partition_${count.index + 15}_sunday"
    job_attempts   = local.batch_coalescer_retry_count
  }

  input = <<EOF
{
    "Parameters" : {
        "s3-bucket-id": "${local.k2hb_aws_s3_archive_bucket_id}",
        "s3-prefix": "${local.ingest_storage_write_locations.s3_base_prefix_ucfs}",
        "partition": "${count.index + 15}",
        "threads": "0",
        "date-to-add": "yesterday",
        "max-files": "${local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]}",
        "max-size": "${local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]}"
    }
}
EOF
}
