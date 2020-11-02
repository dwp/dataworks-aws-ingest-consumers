{
  "start": "-PT3H",
  "periodOverride": "auto",
  "widgets": [
    {
      "type": "metric",
      "x": 15,
      "y": 0,
      "width": 9,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_failures_writing_hbase}",
            {
              "label": "sum_of_hbase_write_failure_occurences"
            } ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "Rate of Hbase Batch Write Failure Occurrences",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 3,
      "width": 12,
      "height": 3,
      "properties": {
        "metrics": [
          [ "${namespace}",
            "${k2hb_metric_name_failed_batches}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "Number of Failed Batches",
        "period": 300,
        "setPeriodToTimeRange": true,
        "stat": "Sum",
        "legend": {
          "position": "hidden"
        },
        "yAxis": {
          "left": {
            "showUnits": false,
            "min": 0,
            "max": 4
          },
          "right": {
            "showUnits": true
          }
        },
        "liveData": false
      }
    },
    {
      "type": "metric",
      "x": 15,
      "y": 18,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "mem_used"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "stat": "Maximum",
        "period": 900,
        "yAxis": {
          "left": {
            "showUnits": true,
            "min": 0
          }
        },
        "title": "Memory Utilisation"
      }
    },
    {
      "type": "metric",
      "x": 21,
      "y": 18,
      "width": 3,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "cpu_usage_nice"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "stat": "Maximum",
        "period": 900,
        "title": "CPU Utilisation",
        "liveData": true,
        "yAxis": {
          "left": {
            "showUnits": true,
            "min": 0
          },
          "right": {
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_lag_per_partition}",
            {
              "label": "consumer_lag_average"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "yAxis": {
          "left": {
            "showUnits": false
          }
        },
        "title": "Average consumer lag over time",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 3,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_messages_written_to_dlq}",
            {
              "label": "DLQ Messages"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 3600,
        "title": "Messages sent to DLQ last hour"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 15,
      "width": 9,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_records}",
            {
              "label": "number_of_records_processed_in_5_minutes"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 300,
        "title": "Rate of Records Processed",
        "yAxis": {
          "left": {
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 12,
      "width": 9,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_records}",
            {
              "label": "average_batch_size_per_5_mins", "yAxis": "left"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "stat": "Average",
        "period": 300,
        "title": "Average Batch Size of Records",
        "yAxis": {
          "left": {
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_speed_of_successfully_processed_batches}",
            {
              "label": "speed_of_successful_batches"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "period": 300,
        "title": "Average Speed of Batch Writes (Seconds)",
        "stat": "Average",
        "liveData": true,
        "yAxis": {
          "left": {
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_batches}",
            {
              "label": "Successful batches"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 3600,
        "title": "Successful batches"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 9,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_timeouts_reading_kafka}",
            {
              "label": "sum_of_kafka_timeout_occurrences"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "Rate of Kafka Read Timeout Occurrences",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 18,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_lag_per_partition}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "yAxis": {
          "left": {
            "label": "Records",
            "min": 0,
            "max": 5,
            "showUnits": false
          },
          "right": {
            "label": "",
            "min": 0,
            "max": 10,
            "showUnits": false
          }
        },
        "title": "Consumer lag is over threshold",
        "period": 3600,
        "annotations": {
          "horizontal": [
            {
              "color": "#2ca02c",
              "label": "All good while in green",
              "value": 100000,
              "fill": "below"
            },
            {
              "color": "#d62728",
              "value": 100000,
              "fill": "above"
            }
          ]
        },
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 15,
      "y": 12,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_lag_per_partition}"
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "yAxis": {
          "left": {
            "label": "Records"
          },
          "right": {
            "label": "",
            "min": 0,
            "max": 10,
            "showUnits": false
          }
        },
        "title": "Consumer lag (per partition)",
        "period": 300,
        "stat": "Minimum"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 24,
      "width": 24,
      "height": 6,
      "properties": {
        "query": "SOURCE '${log_group}' | fields @timestamp, @message, message\n| filter message like /K2HB has stopped running, will attempt to restart it/\n| sort @timestamp desc\n| stats count() by bin(30s)",
        "region": "eu-west-2",
        "stacked": false,
        "view": "timeSeries",
        "title": "Process died and was restarted"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 12,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "${reconciliation_namespace}",
            "${reconciliation_metric_name_successfully_reconciled}"
          ]
        ],
        "region": "eu-west-2",
        "title": "${reconciliation_metric_name_successfully_reconciled}"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 18,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "${reconciliation_namespace}",
            "${reconciliation_metric_name_failed_to_be_reconciled}" ]
        ],
        "region": "eu-west-2",
        "title": "${reconciliation_metric_name_failed_to_be_reconciled}"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 3,
      "width": 6,
      "height": 3,
      "properties": {
        "title": "Unreconciled records after specified age",
        "annotations": {
          "alarms": [
              "${number_of_unreconciled_records_after_specified_age_alarm_arn}"
          ]
        },
        "view": "singleValue"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 6,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${reconciled_lambda_namespace}",
            "${number_of_reconciled_records_metric_name}",
            {
              "label": "Reconciled"
            }
          ],
          [
            "${unreconciled_lambda_namespace}",
            "${number_of_unreconciled_records_metric_name}",
            {
              "label": "Unreconciled"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "title": "Counts of Records",
        "stat": "Average",
        "period": 300
      }
    }
  ]
}
