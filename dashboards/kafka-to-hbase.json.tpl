{
  "start": "-P1D",
  "periodOverride": "auto",
  "widgets": [
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
            "${k2hb_metric_name_number_of_successfully_processed_records}",
            {
              "label": "Successfully written records (24h)"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 86400,
        "title": "Written records (24h)"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_batches}",
            {
              "label": "Successfully written batches (24h)"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 86400,
        "title": "Written batches (24h)"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_failed_batches}",
            {
              "label": "Batches failed to write (24h)"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 86400,
        "title": "Failed batches (24h)"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 0,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_messages_written_to_dlq}",
            {
              "label": "Messages sent to DLQ (24h)"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 86400,
        "title": "DLQ writes (24h)"
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
            "${reconciliation_namespace}",
            "${reconciliation_metric_name_successfully_reconciled}",
            {
              "label": "Reconciled messages (24h)"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "title": "Reconciled writes (24h)",
        "stat": "Sum",
        "period": 86400
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${reconciliation_namespace}",
            "${reconciliation_metric_name_trimmed_records}",
            {
              "label": "Trimmed metadata store records (24h)"
            }
          ]
        ],
        "view": "singleValue",
        "region": "eu-west-2",
        "title": "Trimmed records (24h)",
        "stat": "Sum",
        "period": 86400
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 3,
      "width": 9,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": true,
        "period": 300,
        "stat": "Sum",
        "metrics": [
          [ "${reconciliation_namespace}",
            "${reconciliation_metric_name_successfully_reconciled}",
            {
              "label": "Reconciled messages (5m)"
            }
          ],
          [ "${reconciliation_namespace}",
            "${reconciliation_metric_name_failed_to_be_reconciled}",
            {
              "label": "Unreconciled messages (5m)"
            }
          ]
        ],
        "region": "eu-west-2",
        "title": "Reconciled messages over time"
      }
    },
    {
      "type": "metric",
      "x": 15,
      "y": 3,
      "width": 9,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_records}",
            {
              "label": "Max batch size (5m)"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "eu-west-2",
        "stat": "Maximum",
        "period": 300,
        "title": "Max batch size over time",
        "liveData": true
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 9,
      "width": 12,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_records}",
            {
              "label": "Records processed (5m)"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "stat": "Sum",
        "period": 300,
        "title": "Records processed over time",
        "yAxis": {
          "left": {
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 9,
      "width": 12,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_number_of_successfully_processed_records}",
            {
              "label": "Average batch size (5m)"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "stat": "Average",
        "period": 300,
        "title": "Average batch size over time",
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
      "y": 12,
      "width": 12,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_failures_writing_hbase}",
            {
              "label": "HBase write failures (5m)"
            } ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "HBase write failures over time",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 3,
      "properties": {
        "metrics": [
          [
            "${namespace}",
            "${k2hb_metric_name_timeouts_reading_kafka}",
            {
              "label": "HBase read failures (5m)"
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "HBase read failures (5m)",
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 15,
      "width": 12,
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
      "x": 12,
      "y": 15,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "Unreconciled records after specified age",
        "annotations": {
          "alarms": [
              "${number_of_unreconciled_records_after_specified_age_alarm_arn}"
          ]
        },
        "view": "bar",
        "stacked": true,
        "type": "chart"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 21,
      "width": 12,
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
      "x": 12,
      "y": 21,
      "width": 12,
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
      "type": "log",
      "x": 0,
      "y": 27,
      "width": 24,
      "height": 6,
      "properties": {
        "query": "SOURCE '${log_group}' | filter time_taken != \"\" and message like /Put / and message != \"Put record\"\n | stats min(time_taken) as min_time, avg(time_taken) as average_time, max(time_taken) as max_time by message\n | sort average_time desc",
        "region": "eu-west-2",
        "stacked": false,
        "view": "table",
        "title": "Time taken for inserts"
      }
    }
  ]
}
