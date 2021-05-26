# ECS
# Note that the CONTAINER_VERSION environment variable below is just a dummy
# variable. If you need the ECS service to deploy an updated container version,
# just change that number (to anything). Future work will put proper version
# tags on the container image itself, at which point that psuedo-version
# environment variable can be removed again
resource "aws_ecs_task_definition" "k2hb_reconciliation_ucfs" {
  for_each = local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].partition_lists[local.environment]

  family                   = "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.k2hb_reconciliation_cpu_reconciler
  memory                   = var.k2hb_reconciliation_memory_reconciler
  task_role_arn            = aws_iam_role.k2hb_reconciliation.arn
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role.arn

  tags = merge(
    local.common_tags,
    {
      Name         = "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}-${each.key}"
      Family       = "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}-${each.key}"
      image_digest = var.k2hb_reconciliation_container_version
    }
  )

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.k2hb_reconciliation_cpu_reconciler},
    "image": "${local.k2hb_reconciliation_container_url}",
    "memory": ${var.k2hb_reconciliation_memory_reconciler},
    "name": "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}",
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.k2hb_reconciliation_k2hb["ucfs_reconciliation"].name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}"
      }
    },
    "placementStrategy": [
      {
        "field": "attribute:ecs.availability-zone",
        "type": "spread"
      }
    ],
    "environment": [
      {
        "name": "CONTAINER_VERSION",
        "value": "${var.k2hb_reconciliation_container_version}"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${local.environment}"
      },
      {
        "name": "APPLICATION",
        "value": "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}"
      },
      {
        "name": "APP_VERSION",
        "value": "${var.k2hb_reconciliation_container_version}"
      },
      {
        "name": "COMPONENT",
        "value": "jar_file"
      },
      {
        "name": "CORRELATION_ID",
        "value": "NOT_USED"
      },
      {
        "name": "LOG_LEVEL",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].log_level[local.environment]}"
      },
      {
        "name": "RECONCILER_FIXED_DELAY_MILLIS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].reconciler_fixed_delay_millis}"
      },
      {
        "name": "SECRETS_REGION",
        "value": "${var.region}"
      },
      {
        "name": "SECRETS_METADATA_STORE_PASSWORD_SECRET",
        "value": "${aws_secretsmanager_secret.metadata_store_reconciler.name}"
      },
      {
        "name": "HBASE_TABLE_PATTERN",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].table_pattern}"
      },
      {
        "name": "HBASE_ZOOKEEPER_PARENT",
        "value": "/hbase"
      },
      {
        "name": "HBASE_ZOOKEEPER_PORT",
        "value": "2181"
      },
      {
        "name": "HBASE_ZOOKEEPER_QUORUM",
        "value": "${data.terraform_remote_state.internal_compute.outputs.hbase_fqdn}"
      },
      {
        "name": "HBASE_RPC_TIMEOUT_MS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_rpc_timeout_ms[local.environment]}"
      },
      {
        "name": "HBASE_RPC_READ_TIMEOUT_MS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_rpc_read_timeout_ms[local.environment]}"
      },
      {
        "name": "HBASE_CLIENT_OPERATION_TIMEOUT_MS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_operation_timeout_ms[local.environment]}"
      },
      {
        "name": "HBASE_CLIENT_META_OPERATION_TIMEOUT_MS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_meta_operation_timeout_ms[local.environment]}"
      },
      {
        "name": "HBASE_CLIENT_SCANNER_TIMEOUT_PERIOD_MS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_scanner_timeout_ms[local.environment]}"
      },
      {
        "name": "HBASE_PAUSE_MILLISECONDS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_pause_ms[local.environment]}"
      },
      {
        "name": "HBASE_RETRIES",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_client_retries[local.environment]}"
      },
      {
        "name": "HBASE_REPLICATION_FACTOR",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].hbase_replication_factor[local.environment]}"
      },
      {
        "name": "METADATASTORE_USER",
        "value": "${var.metadata_store_reconciler_username}"
      },
      {
        "name": "METADATASTORE_PASSWORD_SECRET_NAME",
        "value": "${aws_secretsmanager_secret.metadata_store_reconciler.name}"
      },
      {
        "name": "METADATASTORE_DATABASE_NAME",
        "value": "${aws_rds_cluster.metadata_store.database_name}"
      },
      {
        "name": "METADATASTORE_ENDPOINT",
        "value": "${aws_rds_cluster.metadata_store.endpoint}"
      },
      {
        "name": "METADATASTORE_PORT",
        "value": "${aws_rds_cluster.metadata_store.port}"
      },
      {
        "name": "METADATASTORE_TABLE",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].table}"
      },
      {
        "name": "METADATASTORE_CA_CERT_PATH",
        "value": "/certs/AmazonRootCA1.pem"
      },
      {
        "name": "METADATASTORE_USE_AWS_SECRETS",
        "value": "true"
      },
      {
        "name": "METADATASTORE_NUMBER_OF_PARALLEL_UPDATES",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].number_of_parallel_updates[local.environment]}"
      },
      {
        "name": "METADATASTORE_BATCH_SIZE",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].batch_size[local.environment]}"
      },
      {
        "name": "METADATASTORE_START_PARTITION",
        "value": "${each.value.first}"
      },
      {
        "name": "METADATASTORE_END_PARTITION",
        "value": "${each.value.last}"
      },
      {
        "name": "RECONCILER_MINIMUM_AGE_SCALE",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].minimum_age_scale[local.environment]}"
      },
      {
        "name": "RECONCILER_MINIMUM_AGE_UNIT",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].minimum_age_unit[local.environment]}"
      },
      {
        "name": "RECONCILER_LAST_CHECKED_SCALE",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].last_checked_scale[local.environment]}"
      },
      {
        "name": "RECONCILER_LAST_CHECKED_UNIT",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].last_checked_unit[local.environment]}"
      },
      {
        "name": "SPRING_PROFILES_ACTIVE",
        "value": "RECONCILIATION,HBASE"
      },
      {
        "name": "RECONCILER_AUTO_COMMIT_STATEMENTS",
        "value": "${local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].auto_commit_statements[local.environment]}"
      }
    ]
  }
]
DEFINITION

}

resource "aws_ecs_service" "k2hb_reconciliation_ucfs" {
  for_each = local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].partition_lists[local.environment]

  name            = "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}-${each.key}"
  cluster         = data.terraform_remote_state.common.outputs.ecs_cluster_main.id
  task_definition = aws_ecs_task_definition.k2hb_reconciliation_ucfs[each.key].arn
  desired_count   = local.k2hb_reconciliation_task_configs["ucfs_reconciliation"].task_count[local.environment]
  launch_type     = "FARGATE"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.k2hb_reconciliation_names["ucfs_reconciliation"]}-${each.key}"
    }
  )

  network_configuration {
    security_groups = [
      aws_security_group.k2hb_reconciliation.id,
    ]

    subnets = data.terraform_remote_state.ingest.outputs.ingestion_subnets.id
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
