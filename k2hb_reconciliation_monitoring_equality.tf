resource "aws_cloudwatch_log_metric_filter" "number_of_reconciled_records_equality" {
  log_group_name = aws_cloudwatch_log_group.k2hb_reconciliation_k2hb["equality_reconciliation"].name
  name           = local.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["equality_reconciliation"]
  pattern        = "{ $.message = \"Checked batch of records from metadata store\" && $.found != \"0\" }"

  metric_transformation {
    name      = local.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records["equality_reconciliation"]
    namespace = local.cw_k2hb_reconciliation_equality_namespace
    value     = "$.size"
  }
}

resource "aws_cloudwatch_log_metric_filter" "number_of_unreconciled_records_equality" {
  log_group_name = aws_cloudwatch_log_group.k2hb_reconciliation_k2hb["equality_reconciliation"].name
  name           = local.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["equality_reconciliation"]
  pattern        = "{ $.message = \"Checked batch of records from metadata store\" && $.not_found != \"0\" }"

  metric_transformation {
    name      = local.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation["equality_reconciliation"]
    namespace = local.cw_k2hb_reconciliation_equality_namespace
    value     = "$.size"
  }
}
