resource "aws_cloudwatch_log_metric_filter" "number_of_batches_written_filter_k2hb_equalities" {
  log_group_name = local.k2hb_ec2_equality_logs_name
  name           = local.k2hb_metric_name_number_of_successfully_processed_batches
  pattern        = "{ $.message = \"Processed batch\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_number_of_successfully_processed_batches
    namespace = local.cw_k2hb_equality_agent_namespace
    value     = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "rate_of_records_written_filter_k2hb_equalities" {
  log_group_name = local.k2hb_ec2_equality_logs_name
  name           = local.k2hb_metric_name_number_of_successfully_processed_records
  pattern        = "{ $.message = \"Processed batch\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_number_of_successfully_processed_records
    namespace = local.cw_k2hb_equality_agent_namespace
    value     = "$.size"
  }
}

resource "aws_cloudwatch_log_metric_filter" "time_to_process_batch_filter_k2hb_equalities" {
  log_group_name = local.k2hb_ec2_equality_logs_name
  name           = local.k2hb_metric_name_speed_of_successfully_processed_batches
  pattern        = "{ $.message = \"Processed batch\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_speed_of_successfully_processed_batches
    namespace = local.cw_k2hb_equality_agent_namespace
    value     = "$.time_taken"
  }
}

module "rate_of_dlq_messages_written_filter_k2hb_alarm_equalities" {
  source  = "dwp/metric-filter-alarm/aws"
  version = "1.1.6"

  log_group_name      = local.k2hb_ec2_equality_logs_name
  metric_namespace    = local.cw_k2hb_equality_agent_namespace
  pattern             = "{ $.message = \"Error processing record, sending to dlq\" }"
  alarm_name          = "K2HB equalities - Messages written to DLQ in last half an hour"
  alarm_description   = "Managed by ${local.common_tags.Application} repository"
  metric_filter_name  = local.k2hb_metric_name_messages_written_to_dlq
  alarm_action_arns   = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 1800
  threshold           = 0
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
}

module "kafka_read_timeout_occurrences_greater_than_threshold_filter_k2hb_alarm_equalities" {
  source  = "dwp/metric-filter-alarm/aws"
  version = "1.1.6"

  log_group_name      = local.k2hb_ec2_equality_logs_name
  metric_namespace    = local.cw_k2hb_equality_agent_namespace
  pattern             = "{ $.message = \"Error reading from Kafka\" }"
  alarm_name          = "K2HB equalities - Kafka read timeout occurrences exceeds 5 in last hour"
  alarm_description   = "Managed by ${local.common_tags.Application} repository"
  metric_filter_name  = local.k2hb_metric_name_timeouts_reading_kafka
  alarm_action_arns   = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 3600
  threshold           = 5
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
}

module "hbase_batch_failures_greater_than_threshold_filter_k2hb_alarm_equalities" {
  source  = "dwp/metric-filter-alarm/aws"
  version = "1.1.6"

  log_group_name      = local.k2hb_ec2_equality_logs_name
  metric_namespace    = local.cw_k2hb_equality_agent_namespace
  pattern             = "{ $.message = \"Failed to put batch into hbase\"}"
  alarm_name          = "K2HB equalities - Hbase write failures exceeds 5 in last hour"
  alarm_description   = "Managed by ${local.common_tags.Application} repository"
  metric_filter_name  = local.k2hb_metric_name_failures_writing_hbase
  alarm_action_arns   = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 3600
  threshold           = 5
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
}

module "hbase_connection_timeout_occurrences_greater_than_threshold_filter_k2hb_alarm_equalities" {
  source  = "dwp/metric-filter-alarm/aws"
  version = "1.1.6"

  log_group_name      = local.k2hb_ec2_equality_logs_name
  metric_namespace    = local.cw_k2hb_equality_agent_namespace
  pattern             = "{ $.message = \"Error connecting to Hbase\" }"
  alarm_name          = "K2HB equalities - Hbase connection timeout occurrences exceeds 5 in last hour"
  alarm_description   = "Managed by ${local.common_tags.Application} repository"
  metric_filter_name  = local.k2hb_metric_name_timeouts_connecting_hbase
  alarm_action_arns   = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 3600
  threshold           = 5
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
}

resource "aws_cloudwatch_log_metric_filter" "consumer_lag_k2hb_equalities" {
  log_group_name = local.k2hb_ec2_equality_logs_name
  name           = local.k2hb_metric_name_lag_per_partition
  pattern        = "{ $.message = \"Put record\"  }"

  metric_transformation {
    name      = local.k2hb_metric_name_lag_per_partition
    namespace = local.cw_k2hb_equality_agent_namespace
    value     = "$.time_since_last_modified"
  }
}

resource "aws_cloudwatch_metric_alarm" "consumer_lag_k2hb_alarm_equalities" {
  metric_name = aws_cloudwatch_log_metric_filter.consumer_lag_k2hb_equalities.name

  namespace           = local.cw_k2hb_equality_agent_namespace
  alarm_name          = "K2HB equalities - Average consumer lag (per partition) over 100 thousand for 3 of the last 4 hours"
  alarm_description   = "Managed by ${local.common_tags.Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 120
  period              = 120
  datapoints_to_alarm = 90
  threshold           = 100000
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"

  tags = merge(
    local.common_tags,
    {
      Name = "consumer-lag-k2hb-alarm-equalities"
    },
  )
}

resource "aws_cloudwatch_log_metric_filter" "failed_k2hb_batches_equalities" {
  log_group_name = local.k2hb_ec2_equality_logs_name
  name           = local.k2hb_metric_name_failed_batches
  pattern        = "{ $.message = \"Batch failed, not committing offset, resetting position to last commit\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_failed_batches
    namespace = local.cw_k2hb_equality_agent_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed_k2hb_batches_exceeds_threshold_equalities" {
  metric_name = aws_cloudwatch_log_metric_filter.failed_k2hb_batches_equalities.name

  namespace           = local.cw_k2hb_equality_agent_namespace
  alarm_name          = "K2HB equalities - Failed batches exceeds 5 in last 30 minutes"
  alarm_description   = "Managed by ${local.common_tags.Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 1800
  datapoints_to_alarm = 1
  threshold           = 5
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  tags = merge(
    local.common_tags,
    {
      Name = "failed-k2hb-batches-exceeds-threshold-equalities"
    },
  )
}
