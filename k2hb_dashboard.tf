resource "aws_cloudwatch_dashboard" "k2hb" {
  dashboard_name = "kafka-to-hbase"
  dashboard_body = templatefile("${path.module}/dashboards/kafka-to-hbase.json.tpl", {
    namespace                                                 = local.cw_k2hb_agent_namespace
    reconciled_lambda_namespace                               = data.terraform_remote_state.ingest.outputs.locals.cw_lambda_metadata_reconciled_namespace
    unreconciled_lambda_namespace                                  = data.terraform_remote_state.ingest.outputs.locals.cw_lambda_metadata_unreconciled_namespace
    reconciliation_namespace                                  = data.terraform_remote_state.ingest.outputs.locals.cw_k2hb_reconciliation_ucfs_namespace
    log_group                                                 = data.terraform_remote_state.ingest.outputs.log_groups.k2hb_ec2_logs.name
    k2hb_metric_name_number_of_successfully_processed_records = local.k2hb_metric_name_number_of_successfully_processed_records
    k2hb_metric_name_speed_of_successfully_processed_batches  = local.k2hb_metric_name_speed_of_successfully_processed_batches
    k2hb_metric_name_number_of_successfully_processed_batches = local.k2hb_metric_name_number_of_successfully_processed_batches
    k2hb_metric_name_messages_written_to_dlq                  = local.k2hb_metric_name_messages_written_to_dlq
    k2hb_metric_name_timeouts_reading_kafka                   = local.k2hb_metric_name_timeouts_reading_kafka
    k2hb_metric_name_failures_writing_hbase                   = local.k2hb_metric_name_failures_writing_hbase
    k2hb_metric_name_timeouts_connecting_hbase                = local.k2hb_metric_name_timeouts_connecting_hbase
    k2hb_metric_name_lag_per_partition                        = local.k2hb_metric_name_lag_per_partition
    k2hb_metric_name_failed_batches                           = local.k2hb_metric_name_failed_batches
    reconciliation_metric_name_successfully_reconciled        = data.terraform_remote_state.ingest.outputs.locals.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["ucfs_reconciliation"]
    reconciliation_metric_name_failed_to_be_reconciled        = data.terraform_remote_state.ingest.outputs.locals.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["ucfs_reconciliation"]
    number_of_unreconciled_records_metric_name                     = data.terraform_remote_state.ingest.outputs.locals.number_of_unreconciled_records_metric_name.ucfs
    number_of_reconciled_records_metric_name                       = data.terraform_remote_state.ingest.outputs.locals.number_of_reconciled_records_metric_name.ucfs
    number_of_unreconciled_records_after_specified_age_metric_name = data.terraform_remote_state.ingest.outputs.locals.number_of_unreconciled_records_after_specified_age_metric_name.ucfs
    number_of_unreconciled_records_after_specified_age_alarm_arn   = data.terraform_remote_state.ingest.outputs.metrics.number_of_unreconciled_records_after_specified_age_alarm.ucfs.arn

  })
}

resource "aws_cloudwatch_dashboard" "k2hb_equality" {
  dashboard_name = "kafka-to-hbase-equality"
  dashboard_body = templatefile("${path.module}/dashboards/kafka-to-hbase.json.tpl", {
    namespace                                                 = local.cw_k2hb_equality_agent_namespace
    reconciled_lambda_namespace                                    = data.terraform_remote_state.ingest.outputs.locals.cw_lambda_metadata_reconciled_namespace
    unreconciled_lambda_namespace                                  = data.terraform_remote_state.ingest.outputs.locals.cw_lambda_metadata_unreconciled_namespace
    reconciliation_namespace                                  = data.terraform_remote_state.ingest.outputs.locals.cw_k2hb_reconciliation_equality_namespace
    log_group                                                 = data.terraform_remote_state.ingest.outputs.log_groups.k2hb_ec2_equality_logs.name
    k2hb_metric_name_number_of_successfully_processed_records = local.k2hb_metric_name_number_of_successfully_processed_records
    k2hb_metric_name_speed_of_successfully_processed_batches  = local.k2hb_metric_name_speed_of_successfully_processed_batches
    k2hb_metric_name_number_of_successfully_processed_batches = local.k2hb_metric_name_number_of_successfully_processed_batches
    k2hb_metric_name_messages_written_to_dlq                  = local.k2hb_metric_name_messages_written_to_dlq
    k2hb_metric_name_timeouts_reading_kafka                   = local.k2hb_metric_name_timeouts_reading_kafka
    k2hb_metric_name_failures_writing_hbase                   = local.k2hb_metric_name_failures_writing_hbase
    k2hb_metric_name_timeouts_connecting_hbase                = local.k2hb_metric_name_timeouts_connecting_hbase
    k2hb_metric_name_lag_per_partition                        = local.k2hb_metric_name_lag_per_partition
    k2hb_metric_name_failed_batches                           = local.k2hb_metric_name_failed_batches
    reconciliation_metric_name_successfully_reconciled        = data.terraform_remote_state.ingest.outputs.locals.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["equality_reconciliation"]
    reconciliation_metric_name_failed_to_be_reconciled        = data.terraform_remote_state.ingest.outputs.locals.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["equality_reconciliation"]
    number_of_unreconciled_records_metric_name                     = data.terraform_remote_state.ingest.outputs.locals.number_of_unreconciled_records_metric_name.equality
    number_of_reconciled_records_metric_name                       = data.terraform_remote_state.ingest.outputs.locals.number_of_reconciled_records_metric_name.equality
    number_of_unreconciled_records_after_specified_age_metric_name = data.terraform_remote_state.ingest.outputs.locals.number_of_unreconciled_records_after_specified_age_metric_name.equality
    number_of_unreconciled_records_after_specified_age_alarm_arn   = data.terraform_remote_state.ingest.outputs.metrics.number_of_unreconciled_records_after_specified_age_alarm.equality.arn

  })
}
