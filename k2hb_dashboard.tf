resource "aws_cloudwatch_dashboard" "k2hb" {
  dashboard_name = "kafka-to-hbase-main"
  dashboard_body = templatefile("${path.module}/dashboards/kafka-to-hbase.json.tpl", {
    namespace                                                 = local.cw_k2hb_main_agent_namespace
    reconciliation_namespace                                  = local.cw_k2hb_reconciliation_ucfs_namespace
    trimmer_namespace                                         = local.cw_k2hb_reconciliation_trimmer_namespace["ucfs_reconciliation"]
    log_group                                                 = local.ingest_log_groups.k2hb_ec2_logs.name
    k2hb_metric_name_number_of_successfully_processed_records = local.k2hb_metric_name_number_of_successfully_processed_records
    k2hb_metric_name_speed_of_successfully_processed_batches  = local.k2hb_metric_name_speed_of_successfully_processed_batches
    k2hb_metric_name_number_of_successfully_processed_batches = local.k2hb_metric_name_number_of_successfully_processed_batches
    k2hb_metric_name_messages_written_to_dlq                  = local.k2hb_metric_name_messages_written_to_dlq
    k2hb_metric_name_timeouts_reading_kafka                   = local.k2hb_metric_name_timeouts_reading_kafka
    k2hb_metric_name_failures_writing_hbase                   = local.k2hb_metric_name_failures_writing_hbase
    k2hb_metric_name_failed_batches                           = local.k2hb_metric_name_failed_batches
    reconciliation_metric_name_successfully_reconciled        = local.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["ucfs_reconciliation"]
    reconciliation_metric_name_failed_to_be_reconciled        = local.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["ucfs_reconciliation"]
    reconciliation_metric_name_trimmed_records                = local.k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed["ucfs_reconciliation"]
    k2hb_metric_name_lag_per_partition                        = local.k2hb_metric_name_lag_per_partition
  })
}

resource "aws_cloudwatch_dashboard" "k2hb_equality" {
  dashboard_name = "kafka-to-hbase-equality"
  dashboard_body = templatefile("${path.module}/dashboards/kafka-to-hbase.json.tpl", {
    namespace                                                 = local.cw_k2hb_equality_agent_namespace
    reconciliation_namespace                                  = local.cw_k2hb_reconciliation_equality_namespace
    trimmer_namespace                                         = local.cw_k2hb_reconciliation_trimmer_namespace["equality_reconciliation"]
    log_group                                                 = local.ingest_log_groups.k2hb_ec2_equality_logs.name
    k2hb_metric_name_number_of_successfully_processed_records = local.k2hb_metric_name_number_of_successfully_processed_records
    k2hb_metric_name_speed_of_successfully_processed_batches  = local.k2hb_metric_name_speed_of_successfully_processed_batches
    k2hb_metric_name_number_of_successfully_processed_batches = local.k2hb_metric_name_number_of_successfully_processed_batches
    k2hb_metric_name_messages_written_to_dlq                  = local.k2hb_metric_name_messages_written_to_dlq
    k2hb_metric_name_timeouts_reading_kafka                   = local.k2hb_metric_name_timeouts_reading_kafka
    k2hb_metric_name_failures_writing_hbase                   = local.k2hb_metric_name_failures_writing_hbase
    k2hb_metric_name_failed_batches                           = local.k2hb_metric_name_failed_batches
    reconciliation_metric_name_successfully_reconciled        = local.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["equality_reconciliation"]
    reconciliation_metric_name_failed_to_be_reconciled        = local.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["equality_reconciliation"]
    reconciliation_metric_name_trimmed_records                = local.k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed["equality_reconciliation"]
    k2hb_metric_name_lag_per_partition                        = local.k2hb_metric_name_lag_per_partition
  })
}

resource "aws_cloudwatch_dashboard" "k2hb_audit" {
  dashboard_name = "kafka-to-hbase-audit"
  dashboard_body = templatefile("${path.module}/dashboards/kafka-to-hbase.json.tpl", {
    namespace                                                 = local.cw_k2hb_audit_agent_namespace
    reconciliation_namespace                                  = local.cw_k2hb_reconciliation_audit_namespace
    trimmer_namespace                                         = local.cw_k2hb_reconciliation_trimmer_namespace["audit_reconciliation"]
    log_group                                                 = local.k2hb_ec2_audit_logs_name
    k2hb_metric_name_number_of_successfully_processed_records = local.k2hb_metric_name_number_of_successfully_processed_records
    k2hb_metric_name_speed_of_successfully_processed_batches  = local.k2hb_metric_name_speed_of_successfully_processed_batches
    k2hb_metric_name_number_of_successfully_processed_batches = local.k2hb_metric_name_number_of_successfully_processed_batches
    k2hb_metric_name_messages_written_to_dlq                  = local.k2hb_metric_name_messages_written_to_dlq
    k2hb_metric_name_timeouts_reading_kafka                   = local.k2hb_metric_name_timeouts_reading_kafka
    k2hb_metric_name_failures_writing_hbase                   = local.k2hb_metric_name_failures_writing_hbase
    k2hb_metric_name_failed_batches                           = local.k2hb_metric_name_failed_batches
    reconciliation_metric_name_successfully_reconciled        = local.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["audit_reconciliation"]
    reconciliation_metric_name_failed_to_be_reconciled        = local.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["audit_reconciliation"]
    reconciliation_metric_name_trimmed_records                = local.k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed["audit_reconciliation"]
    k2hb_metric_name_lag_per_partition                        = local.k2hb_metric_name_lag_per_partition
  })
}
