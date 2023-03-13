resource "aws_cloudwatch_log_metric_filter" "number_of_batches_written_filter_k2hb_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_number_of_successfully_processed_batches
  pattern        = "{ $.message = \"Processed batch\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_number_of_successfully_processed_batches
    namespace = local.cw_k2hb_main_agent_namespace
    value     = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "rate_of_records_written_filter_k2hb_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_number_of_successfully_processed_records
  pattern        = "{ $.message = \"Processed batch\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_number_of_successfully_processed_records
    namespace = local.cw_k2hb_main_agent_namespace
    value     = "$.size"
  }
}

resource "aws_cloudwatch_log_metric_filter" "time_to_process_batch_filter_k2hb_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_speed_of_successfully_processed_batches
  pattern        = "{ $.message = \"Processed batch\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_speed_of_successfully_processed_batches
    namespace = local.cw_k2hb_main_agent_namespace
    value     = "$.time_taken"
  }
}

resource "aws_cloudwatch_log_metric_filter" "rate_of_dlq_messages_written_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_messages_written_to_dlq
  pattern        = "{ $.message = \"Error processing record, sending to dlq\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_messages_written_to_dlq
    namespace = local.cw_k2hb_main_agent_namespace
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "rate_of_dlq_messages_written_ucfs" {
  count       = local.k2hb_alarm_on_dlq_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.rate_of_dlq_messages_written_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Messages written to DLQ in last half an hour"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 1800
  threshold           = 0
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"

  tags = merge(
    local.common_tags,
    {
      Name              = "dlq-written-rate-alarm-ucfs",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_log_metric_filter" "kafka_read_timeout_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_timeouts_reading_kafka
  pattern        = "{ $.message = \"Error reading from Kafka\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_timeouts_reading_kafka
    namespace = local.cw_k2hb_main_agent_namespace
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "kafka_read_timeout_ucfs" {
  count       = local.k2hb_alarm_on_kafka_read_timeouts_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.kafka_read_timeout_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Kafka read timeout occurrences exceeds 5 in last hour"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 3600
  threshold           = 5
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"

  tags = merge(
    local.common_tags,
    {
      Name              = "kafka-read-timeouts-ucfs",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_log_metric_filter" "kafka_write_timeout_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_failures_writing_hbase
  pattern        = "{ $.message = \"Failed to put batch into hbase\"}"

  metric_transformation {
    name      = local.k2hb_metric_name_failures_writing_hbase
    namespace = local.cw_k2hb_main_agent_namespace
    value     = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "kafka_connection_timeout_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_timeouts_connecting_hbase
  pattern        = "{ $.message = \"Error connecting to Hbase\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_timeouts_connecting_hbase
    namespace = local.cw_k2hb_main_agent_namespace
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "kafka_connection_timeout_ucfs" {
  count       = local.k2hb_alarm_on_hbase_connection_timeouts_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.kafka_connection_timeout_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Kafka connection failures exceeds 5 in last hour"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 3600
  threshold           = 5
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"

  tags = merge(
    local.common_tags,
    {
      Name              = "kafka-connection-timeouts-ucfs",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_log_metric_filter" "consumer_lag_k2hb_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_lag_per_partition
  pattern        = "{ $.message = \"Put record\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_lag_per_partition
    namespace = local.cw_k2hb_main_agent_namespace
    value     = "$.time_since_last_modified"
  }
}

resource "aws_cloudwatch_metric_alarm" "consumer_lag_k2hb_alarm_ucfs" {
  count       = local.k2hb_alarm_on_consumer_lag_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.consumer_lag_k2hb_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Average consumer lag (per partition) over 100 thousand for 3 of the last 4 hours"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
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
      Name              = "consumer-lag-k2hb-alarm-ucfs",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_log_metric_filter" "failed_k2hb_batches_ucfs" {
  log_group_name = local.k2hb_ec2_business_logs_name
  name           = local.k2hb_metric_name_failed_batches
  pattern        = "{ $.message = \"Batch failed, not committing offset, resetting position to last commit\" }"

  metric_transformation {
    name      = local.k2hb_metric_name_failed_batches
    namespace = local.cw_k2hb_main_agent_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed_k2hb_batches_exceeds_threshold_ucfs" {
  count       = local.k2hb_alarm_on_failed_batches_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.failed_k2hb_batches_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Failed batches exceeds 50 in last 30 minutes"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 1
  period              = 1800
  datapoints_to_alarm = 1
  threshold           = 50
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  tags = merge(
    local.common_tags,
    {
      Name              = "failed-k2hb-batches-exceeds-threshold-ucfs",
      notification_type = "Warning",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "processed_k2hb_batches_under_threshold_ucfs" {
  count       = local.k2hb_alarm_on_number_of_batches_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.number_of_batches_written_filter_k2hb_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Processed batches under 1000 in 11 of last 12 hours"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 12
  period              = 3600
  datapoints_to_alarm = 11
  threshold           = 1000
  statistic           = "Sum"
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  tags = merge(
    local.common_tags,
    {
      Name                = "processed-k2hb-batches-under-threshold-ucfs",
      notification_type   = "Warning",
      severity            = "Critical",
      active_days         = "Monday+Tuesday+Wednesday+Thursday+Friday+Sunday",
      do_not_alert_before = "11:00",
      do_not_alert_after  = "23:59",
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "processed_k2hb_batches_under_threshold_ucfs_saturday" {
  count       = local.k2hb_alarm_on_number_of_batches_ucfs[local.environment] ? 1 : 0
  metric_name = aws_cloudwatch_log_metric_filter.number_of_batches_written_filter_k2hb_ucfs.name

  namespace           = local.cw_k2hb_main_agent_namespace
  alarm_name          = "K2HB UCFS - Processed batches under 1000 in 20 of last 21 hours (Saturday)"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  evaluation_periods  = 21
  period              = 3600
  datapoints_to_alarm = 20
  threshold           = 1000
  statistic           = "Sum"
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  tags = merge(
    local.common_tags,
    {
      Name                = "processed-k2hb-batches-under-threshold-ucfs-saturday",
      notification_type   = "Warning",
      severity            = "Critical",
      active_days         = "Saturday",
      do_not_alert_before = "17:00",
      do_not_alert_after  = "23:59",
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "k2hb_running_tasks_less_than_desired_main" {
  count               = local.k2hb_alarm_on_running_tasks_less_than_desired_main[local.environment] ? 1 : 0
  alarm_name          = "K2HB main - Running tasks less than desired tasks for 15 minutes"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  treat_missing_data  = "breaching"
  evaluation_periods  = 15
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  metric_query {
    id          = "e1"
    expression  = "IF(m1 < m2, 1, 0)"
    label       = "DesiredCountNotMet"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "GroupInServiceInstances"
      namespace   = "AWS/AutoScaling"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.k2hb_main_london.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "GroupDesiredCapacity"
      namespace   = "AWS/AutoScaling"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.k2hb_main_london.name
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name              = "k2hb-running-tasks-less-than-desired-main",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "k2hb_running_tasks_less_than_desired_main_dedicated" {
  count               = local.k2hb_alarm_on_running_tasks_less_than_desired_main_dedicated[local.environment] ? 1 : 0
  alarm_name          = "K2HB main dedicated - Running tasks less than desired tasks for 15 minutes"
  alarm_description   = "Managed by ${local.common_tags.DWX_Application} repository"
  alarm_actions       = [local.monitoring_topic_arn]
  treat_missing_data  = "breaching"
  evaluation_periods  = 15
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  metric_query {
    id          = "e1"
    expression  = "IF(m1 < m2, 1, 0)"
    label       = "DesiredCountNotMet"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "GroupInServiceInstances"
      namespace   = "AWS/AutoScaling"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.k2hb_main_dedicated_london.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "GroupDesiredCapacity"
      namespace   = "AWS/AutoScaling"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.k2hb_main_dedicated_london.name
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name              = "k2hb-running-tasks-less-than-desired-main-dedicated",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}
