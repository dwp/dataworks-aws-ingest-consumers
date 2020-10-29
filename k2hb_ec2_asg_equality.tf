locals {
  k2hb_equality_tags_asg = merge(
    local.common_tags,
    {
      Name         = "${local.k2hb_equality_consumer_name}-${local.environment}",
      k2hb-version = var.k2hb_version,
      AutoShutdown = local.k2hb_equality_asg_autoshutdown[local.environment],
      SSMEnabled   = local.k2hb_equality_asg_ssmenabled[local.environment],
      Inspector    = local.k2hb_equality_asg_inspector[local.environment],
      Persistence  = "Ignore",
    }
  )
}

resource "aws_launch_template" "k2hb_equality" {
  name                   = "k2hb_equality"
  image_id               = var.al2_hardened_ami_id
  instance_type          = var.k2hb_equality_ec2_size[local.environment]
  vpc_security_group_ids = [aws_security_group.k2hb_equality.id]

  user_data = base64encode(templatefile("k2hb_userdata.tpl", {
    environment_name          = local.environment
    k2hb_version              = var.k2hb_version
    k2hb_application_name     = local.k2hb_equality_consumer_name
    k2hb_kafka_consumer_group = local.k2hb_kafka_equality_consumer_group
    k2hb_log_level            = local.k2hb_log_level[local.environment]

    k2hb_kafka_bootstrap_servers = join(
      ",",
      formatlist(
        "%s:%s",
        data.terraform_remote_state.ingest.outputs.locals.kafka_bootstrap_servers[local.environment],
        data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment],
      ),
    )

    acm_cert_arn          = aws_acm_certificate.kafka_to_hbase.arn
    private_key_alias     = "k2hb"
    truststore_aliases    = local.kafka_consumer_truststore_aliases[local.environment]
    truststore_certs      = local.kafka_consumer_truststore_certs[local.environment]
    internet_proxy        = data.terraform_remote_state.ingest.outputs.internet_proxy.host
    non_proxied_endpoints = join(",", data.terraform_remote_state.ingest.outputs.vpc.vpc.no_proxy_list)
    s3_artefact_bucket_id = data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id

    hbase_master_url                                 = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.fqdn
    k2hb_max_memory_allocation                       = var.k2hb_max_memory_allocation_equality[local.environment]
    cwa_metrics_collection_interval                  = local.cw_agent_metrics_collection_interval
    cwa_namespace                                    = local.cw_k2hb_equality_agent_namespace
    cwa_cpu_metrics_collection_interval              = local.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = local.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = local.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = local.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = local.cw_agent_netstat_metrics_collection_interval
    cwa_log_group_name                               = data.terraform_remote_state.ingest.outputs.log_groups.k2hb_ec2_equality_logs.name
    s3_scripts_bucket                                = data.terraform_remote_state.common.outputs.config_bucket.id
    s3_script_key_k2hb_sh                            = aws_s3_bucket_object.k2hb_shell_script.id
    s3_script_key_k2hb_init                          = aws_s3_bucket_object.k2hb_init_script.id
    s3_script_key_k2hb_logrotate                     = aws_s3_bucket_object.k2hb_logrotate_script.id
    s3_script_k2hb_cloudwatch_sh                     = aws_s3_bucket_object.k2hb_cloudwatch_script.id
    s3_script_common_logging_sh                      = data.terraform_remote_state.common.outputs.application_logging_common_file.s3_id
    s3_script_logging_sh                             = aws_s3_bucket_object.logging_script.id
    s3_script_respawn_k2hb_sh                        = aws_s3_bucket_object.respawn_k2hb_script.id
    s3_script_amazon_root_ca1_pem                    = aws_s3_bucket_object.amazon_root_ca1_pem.id
    s3_script_hash_k2hb_sh                           = md5(data.local_file.k2hb_shell_script.content)
    s3_script_hash_k2hb_init                         = md5(data.local_file.k2hb_init_script.content)
    s3_script_hash_k2hb_logrotate                    = md5(data.local_file.k2hb_logrotate_script.content)
    s3_script_hash_k2hb_cloudwatch_sh                = md5(data.local_file.k2hb_cloudwatch_script.content)
    s3_script_hash_common_logging_sh                 = data.terraform_remote_state.common.outputs.application_logging_common_file.hash
    s3_script_hash_logging_sh                        = md5(data.local_file.logging_script.content)
    s3_script_hash_respawn_k2hb_sh                   = md5(data.local_file.respawn_k2hb_script.content)
    s3_script_hash_amazon_root_ca1_pem               = md5(data.local_file.amazon_root_ca1_pem.content)
    k2hb_hbase_zookeeper_parent                      = "/hbase"
    k2hb_hbase_zookeeper_quorum                      = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.fqdn
    k2hb_hbase_zookeeper_port                        = "2181"
    k2hb_hbase_data_family                           = local.k2hb_data_family[local.environment]
    k2hb_hbase_data_qualifier                        = local.k2hb_data_qualifier[local.environment]
    k2hb_hbase_log_keys                              = local.k2hb_output_hbase_keys[local.environment]
    k2hb_hbase_region_replication                    = local.k2hb_hbase_region_replication[local.environment]
    k2hb_hbase_rpc_timeout_milliseconds              = local.kafka_k2hb_hbase_rpc_timeout_milliseconds[local.environment]
    k2hb_hbase_client_operation_timeout_milliseconds = local.kafka_k2hb_hbase_client_operation_timeout_milliseconds[local.environment]
    k2hb_hbase_pause_milliseconds                    = local.kafka_k2hb_hbase_client_pause_milliseconds[local.environment]
    k2hb_hbase_retries                               = local.kafka_k2hb_hbase_client_retries[local.environment]
    k2hb_retry_max_attempts                          = local.kafka_k2hb_hbase_retry_attempts[local.environment]
    k2hb_use_aws_secrets                             = "true"
    k2hb_rds_username                                = data.terraform_remote_state.ingest.outputs.metadata_store.credentials.metadata_store_k2hbwriter_username
    k2hb_rds_password_secret_name                    = data.terraform_remote_state.ingest.outputs.metadata_store.credentials.metadata_store_k2hbwriter.name
    k2hb_rds_database_name                           = data.terraform_remote_state.ingest.outputs.metadata_store.rds.database_name
    k2hb_rds_table_name                              = data.terraform_remote_state.ingest.outputs.metadata_store_table_names.main
    k2hb_rds_endpoint                                = data.terraform_remote_state.ingest.outputs.metadata_store.rds.endpoint
    k2hb_rds_port                                    = data.terraform_remote_state.ingest.outputs.metadata_store.rds.port
    k2hb_kafka_topic_regex                           = local.kafka_consumer_equality_topics_regex[local.environment]
    k2hb_kafka_meta_refresh_ms                       = local.kafka_k2hb_meta_refresh_ms[local.environment]
    k2hb_kafka_max_poll_interval_ms                  = local.k2hb_max_poll_interval_ms[local.environment]
    k2hb_kafka_poll_timeout                          = local.kafka_k2hb_poll_timeout[local.environment]
    k2hb_kafka_insecure                              = "false"
    k2hb_kafka_cert_mode                             = "RETRIEVE"
    k2hb_kafka_dlq_topic                             = local.dlq_kafka_consumer_topics[local.environment]
    k2hb_kafka_poll_max_records                      = local.k2hb_max_poll_records_count_equality[local.environment]
    k2hb_kafka_report_frequency                      = local.k2hb_report_frequency[local.environment]
    k2hb_qualified_table_pattern                     = local.k2hb_data_equality_qualified_table_pattern
    k2hb_check_existence                             = local.k2hb_check_existence[local.environment]
    k2hb_aws_s3_archive_bucket                       = data.terraform_remote_state.ingest.outputs.corporate_storage_bucket.id
    k2hb_aws_s3_archive_directory                    = "${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_directory_prefix}/${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_bucket_directory.ucfs_equality}"
    k2hb_aws_s3_batch_puts                           = "true"
    k2hb_validator_schema                            = local.k2hb_validator_schema.equality
    k2hb_write_to_metadata_store                     = local.k2hb_equality_write_to_metadata_store[local.environment]
    k2hb_manifest_bucket                             = data.terraform_remote_state.internal_compute.outputs.manifest_bucket.id
    k2hb_manifest_prefix                             = data.terraform_remote_state.ingest.outputs.k2hb_manifest_write_locations.equality_prefix
    k2hb_write_manifests                             = local.k2hb_write_manifests_equality[local.environment]
    k2hb_auto_commit_metadata_store_inserts          = local.k2hb_auto_commit_metadata_store_inserts_equality[local.environment]
  }))

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = aws_iam_instance_profile.k2hb_equality.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 1024
      volume_type           = "io1"
      iops                  = "2000"
      delete_on_termination = true
      encrypted             = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name        = local.k2hb_equality_consumer_name,
      Persistence = "Ignore"
    },
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name        = local.k2hb_equality_consumer_name,
        Application = local.k2hb_equality_consumer_name,
        Persistence = "Ignore"
      },
    )
  }
}

resource "aws_iam_instance_profile" "k2hb_equality" {
  name = "k2hb_equality"
  role = aws_iam_role.k2hb_equality.name
}

resource "aws_autoscaling_group" "k2hb_equality" {
  name_prefix               = "${aws_launch_template.k2hb_equality.name}-lt_ver${aws_launch_template.k2hb_equality.latest_version}_"
  min_size                  = local.k2hb_asg_min[local.environment]
  desired_capacity          = var.k2hb_equality_asg_desired[local.environment]
  max_size                  = var.k2hb_equality_asg_max[local.environment]
  health_check_grace_period = 600
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = data.terraform_remote_state.ingest.outputs.ingestion_subnets.id

  launch_template {
    id      = aws_launch_template.k2hb_equality.id
    version = "$Latest"
  }

  tags = [
    for key, value in local.k2hb_equality_tags_asg :
    {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

data "aws_iam_policy_document" "k2hb_equality" {
  statement {
    sid    = "AllowACM"
    effect = "Allow"

    actions = [
      "acm:*Certificate",
    ]

    resources = [aws_acm_certificate.kafka_to_hbase.arn]
  }

  statement {
    sid    = "GetPublicCerts"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.arn]
  }

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
    sid       = "AllowDescribeASGToCheckLaunchTemplate"
    effect    = "Allow"
    actions   = ["autoscaling:DescribeAutoScalingGroups"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowDescribeEC2LaunchTemplatesToCheckLatestVersion"
    effect    = "Allow"
    actions   = ["ec2:DescribeLaunchTemplates"]
    resources = ["*"]
  }

  statement {
    sid    = "K2HBConsumerKMS"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.ingest.outputs.input_bucket_cmk.arn,
    ]
  }

  statement {
    sid     = "AllowAccessToArtefactBucket"
    effect  = "Allow"
    actions = ["s3:GetBucketLocation"]

    resources = [data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn]
  }

  statement {
    sid       = "AllowPullFromArtefactBucket"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowDecryptArtefactBucket"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [data.terraform_remote_state.management_artefact.outputs.artefact_bucket.cmk_arn]
  }

  statement {
    sid    = "AllowK2HBToAccessLogGroups"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [data.terraform_remote_state.ingest.outputs.log_groups.k2hb_ec2_equality_logs.arn]
  }

  statement {
    sid    = "AllowK2HBToGetSecretManagerPassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.terraform_remote_state.ingest.outputs.metadata_store.credentials.metadata_store_k2hbwriter.arn,
    ]
  }

  statement {
    sid    = "WriteManifestsInManifestBucket"
    effect = "Allow"

    actions = [
      "s3:DeleteObject*",
      "s3:PutObject",
    ]

    resources = [
      "${data.terraform_remote_state.internal_compute.outputs.manifest_bucket.arn}/${data.terraform_remote_state.internal_compute.outputs.manifest_s3_prefixes.base}/*",
    ]
  }

  statement {
    sid    = "ListManifests"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.internal_compute.outputs.manifest_bucket.arn,
    ]
  }

  statement {
    sid    = "AllowKMSEncryptionOfS3ManifestBucketObj"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]


    resources = [
      data.terraform_remote_state.internal_compute.outputs.manifest_bucket_cmk.arn,
    ]
  }
}

data "aws_iam_policy_document" "k2hb_equality_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k2hb_equality" {
  name                 = "k2hb_equality"
  assume_role_policy   = data.aws_iam_policy_document.k2hb_equality_policy.json
  max_session_duration = local.iam_role_max_session_timeout_seconds
  tags                 = local.common_tags
}

resource "aws_iam_policy" "k2hb_equality" {
  name        = "k2hb_equality"
  description = "Policy to allow access for K2HB"
  policy      = data.aws_iam_policy_document.k2hb_equality.json
}

resource "aws_iam_role_policy_attachment" "k2hb_equality" {
  role       = aws_iam_role.k2hb_equality.name
  policy_arn = aws_iam_policy.k2hb_equality.arn
}

resource "aws_iam_role_policy_attachment" "k2hb_equality_cwasp" {
  role       = aws_iam_role.k2hb_equality.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "k2hb_equality_ssm" {
  role       = aws_iam_role.k2hb_equality.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# This updates the broker security group to let us in
resource "aws_security_group_rule" "k2hb_equality_ec2_to_stub_ucfs_kafka" {
  count                    = data.terraform_remote_state.ingest.outputs.stub_ucfs.deploy_stub_broker[local.environment] ? length(data.terraform_remote_state.ingest.outputs.stub_ucfs.stub_ucfs_kafka_ports) : 0
  description              = "K2HB Equality ec2 to stub broker"
  type                     = "ingress"
  source_security_group_id = aws_security_group.k2hb_equality.id
  protocol                 = "tcp"
  from_port                = data.terraform_remote_state.ingest.outputs.stub_ucfs.stub_ucfs_kafka_ports[count.index]
  to_port                  = data.terraform_remote_state.ingest.outputs.stub_ucfs.stub_ucfs_kafka_ports[count.index]
  security_group_id        = data.terraform_remote_state.ingest.outputs.stub_ucfs.sg_id
}

resource "aws_security_group" "k2hb_equality" {
  name                   = "k2hb_equality"
  description            = "Contains rules for k2hb equalities"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.ingest.outputs.vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-equality"
    },
  )
}

resource "aws_security_group_rule" "k2hb_equality_to_s3" {
  description       = "Allow kafka-to-hbase to reach S3 (for the jar)"
  type              = "egress"
  prefix_list_ids   = [data.terraform_remote_state.ingest.outputs.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_s3_http" {
  description       = "Allow kafka-to-hbase to reach S3 (for Yum) http"
  type              = "egress"
  prefix_list_ids   = [data.terraform_remote_state.ingest.outputs.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_stub_broker" {
  count             = data.terraform_remote_state.ingest.outputs.locals.k2hb_data_source_is_ucfs[local.environment] ? 0 : 1 //inverse of aws_security_group_rule.consumer_to_ucfs_broker below
  description       = "Allow k2hb to reach stub Kafka brokers"
  type              = "egress"
  from_port         = data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment]
  to_port           = data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.stub_ucfs_subnets.cidr_block
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_ucfs_broker" {
  count             = data.terraform_remote_state.ingest.outputs.locals.k2hb_data_source_is_ucfs[local.environment] ? 1 : 0 //inverse of aws_security_group_rule.consumer_to_stub_broker above
  description       = "Allow k2hb to reach UCFS Kafka brokers"
  type              = "egress"
  from_port         = data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment]
  to_port           = data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.locals.ucfs_broker_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_ucfs_london_broker" {
  count             = data.terraform_remote_state.ingest.outputs.locals.k2hb_data_source_is_ucfs[local.environment] ? 1 : 0 //inverse of aws_security_group_rule.consumer_to_stub_broker above
  description       = "Allow k2hb to reach UCFS Kafka brokers (London)"
  type              = "egress"
  from_port         = data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment]
  to_port           = data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_broker_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "egress_k2hb_equality_to_internet" {
  description              = "Allow k2hb access to Internet Proxy (for ACM-PCA)"
  type                     = "egress"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.internet_proxy.sg
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "ingress_k2hb_equality_to_internet" {
  description              = "Allow k2hb access to Internet Proxy (for ACM-PCA)"
  type                     = "ingress"
  source_security_group_id = aws_security_group.k2hb_equality.id
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = data.terraform_remote_state.ingest.outputs.internet_proxy.sg
}

resource "aws_security_group_rule" "k2hb_equality_to_dns_name_servers_tcp" {
  count             = data.terraform_remote_state.ingest.outputs.locals.peer_with_ucfs[local.environment] ? 1 : 0
  description       = "Allow consumers to reach ucfs DNS name servers"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.locals.ucfs_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_dns_name_servers_udp" {
  count             = data.terraform_remote_state.ingest.outputs.locals.peer_with_ucfs[local.environment] ? 1 : 0
  description       = "Allow consumers to reach ucfs DNS name servers"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.locals.ucfs_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_ucfs_london_dns_tcp" {
  count             = data.terraform_remote_state.ingest.outputs.locals.peer_with_ucfs_london[local.environment] ? 1 : 0
  description       = "Allow consumers to reach UCFS DNS (London)"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_to_ucfs_london_dns_udp" {
  count             = data.terraform_remote_state.ingest.outputs.locals.peer_with_ucfs_london[local.environment] ? 1 : 0
  description       = "Allow consumers to reach UCFS DNS (London)"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_master_zookeeper" {
  description              = "Allow outbound requests to HBase zookeeper"
  type                     = "egress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_master_16000" {
  description              = "Allow outbound requests to HBase master"
  type                     = "egress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_master_16020" {
  description              = "Allow outbound requests to HBase master"
  type                     = "egress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_master_16030" {
  description              = "Allow outbound requests to HBase master"
  type                     = "egress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_servers_16000" {
  description              = "Allow outbound requests to HBase servers"
  type                     = "egress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.slave_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_servers_16020" {
  description              = "Allow outbound requests to HBase servers"
  type                     = "egress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.slave_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_emr_sservers_16030" {
  description              = "Allow outbound reqests to HBase servers"
  type                     = "egress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.slave_sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "k2hb_equality_egress_metadata_store" {
  description              = "Allow outbound requests to Metadata Store DB"
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.ingest.outputs.metadata_store.rds.sg_id
  security_group_id        = aws_security_group.k2hb_equality.id
}

resource "aws_security_group_rule" "metadata_store_from_k2hb_ec2_equality" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.metadata_store.rds.sg_id
  description              = "Metadata store from K2HB ec2"
}

# These are the security group rules for the EMR connection from this k2hb
resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_master_zookeeper" {
  description              = "Allow all inbound zookeeper requests from k2hb equality"
  type                     = "ingress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_master_16000" {
  description              = "Allow all inbound HBase Region Server requests from k2hb equality"
  type                     = "ingress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_master_16020" {
  description              = "Allow all inbound HBase Region Server requests from k2hb equality"
  type                     = "ingress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_master_16030" {
  description              = "Allow all inbound HBase Region Server requests from k2hb equality"
  type                     = "ingress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.master_sg_id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_servers_16000" {
  description              = "Allow all inbound HBase Master requests from k2hb equality"
  type                     = "ingress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.slave_sg_id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_servers_16020" {
  description              = "Allow all inbound HBase Master requests from k2hb equality"
  type                     = "ingress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.slave_sg_id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_equality_servers_16030" {
  description              = "Allow all inbound HBase Master requests from k2hb equality"
  type                     = "ingress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_equality.id
  security_group_id        = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.slave_sg_id
}
