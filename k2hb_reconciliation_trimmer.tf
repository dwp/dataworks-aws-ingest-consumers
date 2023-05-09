locals {
  k2hb_reconciliation_trimmer_image_url = "${local.account.management}.${local.ingest_vpc_ecr_dkr_domain_name}/kafka-to-hbase-reconciliation${var.k2hb_reconciliation_container_version}"
}


data "aws_secretsmanager_secret" "metadata_store_reconciler" {
  name = "metadata-store-${var.metadata_store_reconciler_username}"
}

resource "aws_iam_role" "ecs_instance_role_k2hb_reconciliation_trimmer_batch" {
  name = "ecs_instance_role_k2hb_reconciliation_trimmer_batch"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
}
EOF

  tags = merge(
    local.common_tags,
    { Name = "k2hb_reconciliation_trimmer" }
  )
}

resource "aws_iam_role_policy_attachment" "k2hb_reconciliation_trimmer_ecs_cwasp" {
  role       = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_k2hb_reconciliation_trimmer_batch" {
  role       = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role_k2hb_reconciliation_trimmer_batch" {
  name = "ecs_instance_role_k2hb_reconciliation_trimmer_profile"
  role = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
}

# Custom policy to allow use of default EBS encryption key by Batch instance role
data "aws_iam_policy_document" "ecs_instance_role_k2hb_reconciliation_trimmer_batch_ebs_cmk" {

  statement {
    sid    = "AllowUseDefaultEbsCmk"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [data.terraform_remote_state.security-tools.outputs.ebs_cmk.arn]
  }


  statement {
    effect = "Allow"
    sid    = "AllowAccessToConfigBucket"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [data.terraform_remote_state.common.outputs.config_bucket.arn]
  }

  statement {
    effect = "Allow"
    sid    = "AllowAccessToConfigBucketObjects"

    actions = ["s3:GetObject"]

    resources = ["${data.terraform_remote_state.common.outputs.config_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowKMSDecryptionOfS3ConfigBucketObj"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [data.terraform_remote_state.common.outputs.config_bucket_cmk.arn]
  }

  statement {
    sid    = "AllowAccessLogGroups"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = data.terraform_remote_state.common.outputs.ami_ecs_test_services ? [aws_cloudwatch_log_group.k2hb_reconciliation_trimmer_ecs_cluster.arn, data.terraform_remote_state.common.outputs.ami_ecs_test_log_group_arn] : [aws_cloudwatch_log_group.k2hb_reconciliation_trimmer_ecs_cluster.arn]
  }

  statement {
    sid    = "EnableEC2TaggingHost"
    effect = "Allow"

    actions = [
      "ec2:ModifyInstanceMetadataOptions",
      "ec2:*Tags",
    ]
    resources = ["arn:aws:ec2:${var.region}:${local.account[local.environment]}:instance/*"]
  }

  statement {
    sid    = "ECSListClusters"
    effect = "Allow"

    actions = [
      "ecs:ListClusters",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:*",
    ]

    resources = [
      "*"
    ]
  }

}

resource "aws_cloudwatch_log_group" "k2hb_reconciliation_trimmer_ecs_cluster" {
  name              = local.cw_k2hb_recon_trimmer_agent_log_group_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_iam_policy" "ecs_instance_role_k2hb_reconciliation_trimmer_batch_ebs_cmk" {
  name   = "ecs_instance_role_k2hb_reconciliation_trimmer_batch_ebs_cmk"
  policy = data.aws_iam_policy_document.ecs_instance_role_k2hb_reconciliation_trimmer_batch_ebs_cmk.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_k2hb_reconciliation_trimmer_batch_ebs_cmk" {
  role       = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
  policy_arn = aws_iam_policy.ecs_instance_role_k2hb_reconciliation_trimmer_batch_ebs_cmk.arn
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_k2hb_reconciliation_trimmer_batch_ecr" {
  role       = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "k2hb_reconciliation_trimmer_job" {
  name               = "k2hb_reconciliation_trimmer_job"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_policy.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "k2hb_reconciliation_trimmer_job" {
  statement {
    sid    = "AllowSSMGet"
    effect = "Allow"

    actions = [
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${local.ingest_input_bucket_arn}", # aws_s3_bucket.input.id
      "arn:aws:s3:::${local.ingest_input_bucket_arn}/${local.ucfs_historic_data_prefix}/*",
    ]
  }
  statement {
    sid    = "GetPassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret.metadata_store_reconciler.arn,
    ]
  }
}

resource "aws_iam_policy" "k2hb_reconciliation_trimmer_job" {
  name   = "k2hb_reconciliation_trimmer_job"
  policy = data.aws_iam_policy_document.k2hb_reconciliation_trimmer_job.json
}

resource "aws_iam_role_policy_attachment" "k2hb_reconciliation_trimmer_job" {
  role       = aws_iam_role.k2hb_reconciliation_trimmer_job.name
  policy_arn = aws_iam_policy.k2hb_reconciliation_trimmer_job.arn
}

resource "aws_iam_role_policy_attachment" "hbase_table_provisioner_job_ecs" {
  role       = aws_iam_role.k2hb_reconciliation_trimmer_job.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security group
resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_to_s3" {
  description       = "Allow k2hb reconciliation trimmer ECS to reach S3 (for Docker pull from ECR)"
  type              = "egress"
  prefix_list_ids   = [local.ingest_vpc_prefix_list_ids_s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
}

resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_egress_hbase" {
  for_each                 = { for hbase_emr_port in local.hbase_emr_ports : hbase_emr_port.port => hbase_emr_port }
  description              = "Allow outbound requests to ${each.value.name}"
  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.common_sg_id
}

resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_ingress_hbase" {
  for_each                 = { for hbase_emr_port in local.hbase_emr_ports : hbase_emr_port.port => hbase_emr_port }
  description              = "Allow inbound requests from ${each.value.name}"
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.common_sg_id
}

resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_egress_rds" {
  description              = "Allow outbound requests to metadatastore RDS"
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
  source_security_group_id = data.terraform_remote_state.ingest.outputs.metadata_store.rds.sg_id
}

resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_ingress_rds" {
  description              = "Allow inbound requests from metadatastore RDS"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
  source_security_group_id = data.terraform_remote_state.ingest.outputs.metadata_store.rds.sg_id
}

resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_egress_internet_proxy" {
  description              = "k2hb recon trimmer batch to Internet Proxy (for hcs services)"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  source_security_group_id = local.ingest_internet_proxy.sg
  security_group_id        = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
}
resource "aws_security_group_rule" "k2hb_reconciliation_trimmer_ingress_internet_proxy" {
  description              = "Allow proxy access from k2hb recon trimmer batch"
  type                     = "ingress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id
  security_group_id        = local.ingest_internet_proxy.sg
}


resource "aws_batch_compute_environment" "k2hb_reconciliation_trimmer_batch" {
  compute_environment_name_prefix = "k2hb_reconciliation_trimmer_"
  service_role                    = data.aws_iam_role.aws_batch_service_role.arn
  type                            = "MANAGED"

  compute_resources {

    instance_role = aws_iam_instance_profile.ecs_instance_role_k2hb_reconciliation_trimmer_batch.arn
    instance_type = ["optimal"]

    min_vcpus     = 0
    desired_vcpus = 0
    max_vcpus     = 8

    security_group_ids = [data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id]
    subnets            = data.terraform_remote_state.ingest.outputs.ingestion_subnets.id
    type               = "EC2"

    launch_template {
      launch_template_id      = aws_launch_template.k2hb_reconciliation_trimmer_ecs_cluster.id
      version                 = aws_launch_template.k2hb_reconciliation_trimmer_ecs_cluster.latest_version
    }

    tags = merge(
      local.common_tags,
      {
        Name         = "k2hb-reconciliation-trimmer",
        Persistence  = "Ignore",
        AutoShutdown = "False",
      }
    )
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [compute_resources.0.desired_vcpus]
  }
}

resource "aws_launch_template" "k2hb_reconciliation_trimmer_ecs_cluster" {
  name     = "k2hb-reconciliation-trimmer"
  image_id = var.ecs_hardened_ami_id

  user_data = base64encode(templatefile("files/batch/userdata.tpl", {
    region                                           = data.aws_region.current.name
    name                                             = "k2hb-reconciliation-trimmer"
    proxy_port                                       = var.proxy_port
    proxy_host                                       = local.ingest_internet_proxy.host
    hcs_environment                                  = local.hcs_environment[local.environment]
    s3_scripts_bucket                                = data.terraform_remote_state.common.outputs.config_bucket.id
    s3_script_logrotate                              = aws_s3_object.batch_logrotate_script.id
    s3_script_cloudwatch_shell                       = aws_s3_object.batch_cloudwatch_script.id
    s3_script_logging_shell                          = aws_s3_object.batch_logging_script.id
    s3_script_config_hcs_shell                       = aws_s3_object.batch_config_hcs.id
    cwa_namespace                                    = local.cw_k2hb_recon_trimmer_agent_namespace
    cwa_log_group_name                               = "${local.cw_k2hb_recon_trimmer_agent_namespace}-${local.environment}"
    cwa_metrics_collection_interval                  = local.cw_agent_metrics_collection_interval
    cwa_cpu_metrics_collection_interval              = local.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = local.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = local.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = local.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = local.cw_agent_netstat_metrics_collection_interval

  }))

  instance_initiated_shutdown_behavior = "terminate"

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-reconciliation-trimmer"
    }
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name                = "k2hb-reconciliation-trimmer",
        AutoShutdown        = local.k2hb_main_asg_autoshutdown[local.environment],
        SSMEnabled          = local.k2hb_main_asg_ssmenabled[local.environment],
        Persistence         = "Ignore",
        propagate_at_launch = true,
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "k2hb-reconciliation-trimmer",
      }
    )
  }
}

resource "aws_batch_job_queue" "k2hb_reconciliation_trimmer_queue" {
  compute_environments = [aws_batch_compute_environment.k2hb_reconciliation_trimmer_batch.arn]
  name                 = "k2hb_reconciliation_trimmer"
  priority             = 10
  state                = "ENABLED"
}

resource "aws_batch_job_definition" "k2hb_reconciliation_trimmer_job" {
  name = "k2hb_reconciliation_trimmer_job"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
{
    "command": ["Ref::metadatastore_table"],
    "image": "${local.k2hb_reconciliation_trimmer_image_url}",
    "jobRoleArn" : "${aws_iam_role.k2hb_reconciliation_trimmer_job.arn}",
    "memory": 1024,
    "vcpus": 2,
    "environment": [
      {"name": "CONTAINER_VERSION","value": "${var.k2hb_reconciliation_container_version}"},
      {"name": "ENVIRONMENT","value": "${local.environment}"},
      {"name": "APPLICATION","value": "k2hb-reconciliation-trimmer"},
      {"name": "APP_VERSION","value": "${var.k2hb_reconciliation_container_version}"},
      {"name": "COMPONENT","value": "jar_file"},
      {"name": "CORRELATION_ID","value": "NOT_USED"},
      {"name": "LOG_LEVEL","value": "${local.k2hb_trimmer_common_config.log_level[local.environment]}"},
      {"name": "HBASE_TABLE_PATTERN","value": "NOT_SET"},
      {"name": "SECRETS_REGION","value": "${var.region}"},
      {"name": "SECRETS_METADATA_STORE_PASSWORD_SECRET","value": "${data.aws_secretsmanager_secret.metadata_store_reconciler.name}"},
      {"name": "METADATASTORE_USER","value": "${var.metadata_store_reconciler_username}"},
      {"name": "METADATASTORE_PASSWORD_SECRET_NAME","value": "${data.aws_secretsmanager_secret.metadata_store_reconciler.name}"},
      {"name": "METADATASTORE_DATABASE_NAME","value": "${data.terraform_remote_state.ingest.outputs.metadata_store.rds.database_name}"},
      {"name": "METADATASTORE_ENDPOINT","value": "${data.terraform_remote_state.ingest.outputs.metadata_store.rds.endpoint}"},
      {"name": "METADATASTORE_PORT","value": "${data.terraform_remote_state.ingest.outputs.metadata_store.rds.port}"},
      {"name": "METADATASTORE_CA_CERT_PATH","value": "/certs/AmazonRootCA1.pem"},
      {"name": "METADATASTORE_USE_AWS_SECRETS","value": "true"},
      {"name": "METADATASTORE_NUMBER_OF_PARALLEL_UPDATES","value": "${local.k2hb_trimmer_common_config.number_of_parallel_updates}"},
      {"name": "METADATASTORE_BATCH_SIZE","value": "${local.k2hb_trimmer_common_config.batch_size}" },
      {"name": "SPRING_PROFILES_ACTIVE","value": "${local.k2hb_trimmer_common_config.spring_profiles_active[local.environment]}" },
      {"name": "RECONCILER_OPTIMIZE_AFTER_DELETE","value": "${local.k2hb_trimmer_common_config.optimize_after_delete[local.environment]}"}
    ],
    "ulimits": [
      {
        "hardLimit": 1024,
        "name": "nofile",
        "softLimit": 1024
      }
    ]
}
CONTAINER_PROPERTIES
}
