resource "aws_cloudwatch_log_metric_filter" "number_of_trimmed_records_equality" {
  log_group_name = local.k2hb_reconciliation_trimmer_log_group_name
  name           = local.k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed["equality_reconciliation"]
  pattern        = "{ $.message = \"Deleted records in Metadata Store\" && $.table = \"${local.ingest_metadata_store_table_names["equality"]}\" }"

  metric_transformation {
    name      = local.k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed["equality_reconciliation"]
    namespace = local.cw_k2hb_reconciliation_trimmer_namespace["equality_reconciliation"]
    value     = "$.deleted_count"
  }
}
