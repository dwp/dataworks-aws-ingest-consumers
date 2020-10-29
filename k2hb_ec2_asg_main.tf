locals {
  k2hb_main_tags_asg = merge(
    local.common_tags,
    {
      Name         = "${local.k2hb_main_ha_cluster_consumer_name}-${local.environment}",
      k2hb-version = var.k2hb_version,
      AutoShutdown = local.k2hb_main_asg_autoshutdown[local.environment],
      SSMEnabled   = local.k2hb_main_asg_ssmenabled[local.environment],
      Inspector    = local.k2hb_main_asg_inspector[local.environment],
      Persistence  = "Ignore",
    }
  )
}

resource "aws_launch_template" "k2hb_main_ha_cluster" {
  name                   = "k2hb_main_ha_cluster"
  image_id               = var.al2_hardened_ami_id
  instance_type          = var.k2hb_main_ec2_size[local.environment]
  vpc_security_group_ids = [aws_security_group.k2hb_main.id]

  user_data = base64encode(templatefile("k2hb_userdata.tpl", {
    environment_name          = local.environment
    k2hb_version              = var.k2hb_version
    k2hb_application_name     = local.k2hb_main_ha_cluster_consumer_name
    k2hb_kafka_consumer_group = local.k2hb_kafka_main_consumer_group //different server to old single node broker, so keep the same name
    k2hb_log_level            = local.k2hb_log_level[local.environment]

    k2hb_kafka_bootstrap_servers = join(
      ",",
      formatlist(
        "%s:%s",
        local.kafka_bootstrap_servers[local.environment],
        local.kafka_broker_port[local.environment],
      ),
    )

    acm_cert_arn          = aws_acm_certificate.kafka_to_hbase.arn
    private_key_alias     = "k2hb"
    truststore_aliases    = local.kafka_consumer_truststore_aliases[local.environment]
    truststore_certs      = local.kafka_consumer_truststore_certs[local.environment]
    internet_proxy        = aws_vpc_endpoint.internet_proxy.dns_entry[0].dns_name
    non_proxied_endpoints = join(",", module.vpc.no_proxy_list)
    s3_artefact_bucket_id = data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id

    hbase_master_url                                 = aws_route53_record.hbase.fqdn
    k2hb_max_memory_allocation                       = var.k2hb_max_memory_allocation_main[local.environment]
    cwa_metrics_collection_interval                  = local.cw_agent_metrics_collection_interval
    cwa_namespace                                    = local.cw_k2hb_agent_namespace
    cwa_cpu_metrics_collection_interval              = local.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = local.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = local.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = local.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = local.cw_agent_netstat_metrics_collection_interval
    cwa_log_group_name                               = aws_cloudwatch_log_group.k2hb_ec2_logs.name
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
    k2hb_hbase_zookeeper_quorum                      = aws_route53_record.hbase.fqdn
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
    k2hb_rds_username                                = var.metadata_store_k2hbwriter_username
    k2hb_rds_password_secret_name                    = aws_secretsmanager_secret.metadata_store_k2hbwriter.name
    k2hb_rds_database_name                           = aws_rds_cluster.metadata_store.database_name
    k2hb_rds_table_name                              = local.metadata_store_table_names.ucfs
    k2hb_rds_endpoint                                = aws_rds_cluster.metadata_store.endpoint
    k2hb_rds_port                                    = aws_rds_cluster.metadata_store.port
    k2hb_kafka_topic_regex                           = local.kafka_consumer_main_topics_regex[local.environment]
    k2hb_kafka_meta_refresh_ms                       = local.kafka_k2hb_meta_refresh_ms[local.environment]
    k2hb_kafka_max_poll_interval_ms                  = local.k2hb_max_poll_interval_ms[local.environment]
    k2hb_kafka_poll_timeout                          = local.kafka_k2hb_poll_timeout[local.environment]
    k2hb_kafka_insecure                              = "false"
    k2hb_kafka_cert_mode                             = "RETRIEVE"
    k2hb_kafka_dlq_topic                             = local.dlq_kafka_consumer_topics[local.environment]
    k2hb_kafka_poll_max_records                      = local.k2hb_max_poll_records_count_main[local.environment]
    k2hb_kafka_report_frequency                      = local.k2hb_report_frequency[local.environment]
    k2hb_qualified_table_pattern                     = local.k2hb_main_data_qualified_table_pattern
    k2hb_check_existence                             = local.k2hb_check_existence[local.environment]
    k2hb_aws_s3_archive_bucket                       = aws_s3_bucket.corporate_storage_bucket.id
    k2hb_aws_s3_archive_directory                    = "${local.corporate_storage_directory_prefix}/${local.corporate_storage_bucket_directory.ucfs_main}"
    k2hb_aws_s3_batch_puts                           = "true"
    k2hb_validator_schema                            = local.k2hb_validator_schema.ucfs
    k2hb_write_to_metadata_store                     = local.k2hb_main_ha_cluster_write_to_metadata_store[local.environment]
    k2hb_manifest_bucket                             = data.terraform_remote_state.internal_compute.outputs.manifest_bucket.id
    k2hb_manifest_prefix                             = local.k2hb_manifest_folder_main
    k2hb_write_manifests                             = local.k2hb_write_manifests_main[local.environment]
    k2hb_auto_commit_metadata_store_inserts          = local.k2hb_auto_commit_metadata_store_inserts_main[local.environment]
  }))

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = aws_iam_instance_profile.k2hb_main.arn
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
      Name        = local.k2hb_main_ha_cluster_consumer_name,
      Persistence = "Ignore"
    },
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name        = local.k2hb_main_ha_cluster_consumer_name,
        Application = local.k2hb_main_ha_cluster_consumer_name,
        Persistence = "Ignore"
      },
    )
  }
}

resource "aws_iam_instance_profile" "k2hb_main" {
  name = "k2hb-main"
  role = aws_iam_role.k2hb_main.name
}

resource "aws_autoscaling_group" "k2hb_main_ha_cluster" {
  name_prefix               = "${aws_launch_template.k2hb_main_ha_cluster.name}-lt_ver${aws_launch_template.k2hb_main_ha_cluster.latest_version}_"
  min_size                  = local.k2hb_asg_min[local.environment]
  desired_capacity          = var.k2hb_main_ha_cluster_asg_desired[local.environment]
  max_size                  = var.k2hb_main_ha_cluster_asg_max[local.environment]
  health_check_grace_period = 600
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = aws_subnet.business_data.*.id

  launch_template {
    id      = aws_launch_template.k2hb_main_ha_cluster.id
    version = "$Latest"
  }

  tags = [
    for key, value in local.k2hb_main_tags_asg :
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

data "aws_iam_policy_document" "k2hb_main" {
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
      aws_kms_key.input_bucket_cmk.arn,
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
    resources = [aws_cloudwatch_log_group.k2hb_ec2_logs.arn]
  }

  statement {
    sid    = "AllowK2HBToGetSecretManagerPassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.metadata_store_k2hbwriter.arn,
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

data "aws_iam_policy_document" "k2hb_main_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k2hb_main" {
  name                 = "k2hb_main"
  assume_role_policy   = data.aws_iam_policy_document.k2hb_main_policy.json
  max_session_duration = local.iam_role_max_session_timeout_seconds
  tags                 = local.common_tags
}

resource "aws_iam_policy" "k2hb_main" {
  name        = "k2hb_main"
  description = "Policy to allow access for K2HB"
  policy      = data.aws_iam_policy_document.k2hb_main.json
}

resource "aws_iam_role_policy_attachment" "k2hb_main" {
  role       = aws_iam_role.k2hb_main.name
  policy_arn = aws_iam_policy.k2hb_main.arn
}

resource "aws_iam_role_policy_attachment" "k2hb_main_cwasp" {
  role       = aws_iam_role.k2hb_main.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "k2hb_main_ssm" {
  role       = aws_iam_role.k2hb_main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# This updates the broker security group to let us in
resource "aws_security_group_rule" "k2hb_main_ec2_to_stub_ucfs_kafka" {
  count                    = local.deploy_stub_broker[local.environment] ? length(local.stub_ucfs_kafka_ports) : 0
  description              = "K2HB Main ec2 to stub broker"
  type                     = "ingress"
  source_security_group_id = aws_security_group.k2hb_main.id
  protocol                 = "tcp"
  from_port                = local.stub_ucfs_kafka_ports[count.index]
  to_port                  = local.stub_ucfs_kafka_ports[count.index]
  security_group_id        = aws_security_group.stub_ucfs_kafka.id
}

resource "aws_security_group" "k2hb_main" {
  name                   = "k2hb_main"
  description            = "Contains rules for k2hb"
  revoke_rules_on_delete = true
  vpc_id                 = module.vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-main"
    },
  )
}

resource "aws_security_group_rule" "k2hb_main_to_s3" {
  description       = "Allow kafka-to-hbase to reach S3 (for the jar)"
  type              = "egress"
  prefix_list_ids   = [module.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_s3_http" {
  description       = "Allow kafka-to-hbase to reach S3 (for Yum) http"
  type              = "egress"
  prefix_list_ids   = [module.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_stub_broker" {
  count             = local.k2hb_data_source_is_ucfs[local.environment] ? 0 : 1
  description       = "Allow k2hb to reach stub Kafka brokers"
  type              = "egress"
  from_port         = local.kafka_broker_port[local.environment]
  to_port           = local.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = aws_subnet.stub_ucfs.*.cidr_block
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_ucfs_broker" {
  count             = local.k2hb_data_source_is_ucfs[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach UCFS Kafka brokers"
  type              = "egress"
  from_port         = local.kafka_broker_port[local.environment]
  to_port           = local.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_broker_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_ucfs_london_broker" {
  count             = local.k2hb_data_source_is_ucfs[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach UCFS Kafka brokers (London)"
  type              = "egress"
  from_port         = local.kafka_broker_port[local.environment]
  to_port           = local.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_london_broker_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "egress_k2hb_main_to_internet" {
  description              = "Allow k2hb access to Internet Proxy (for ACM-PCA)"
  type                     = "egress"
  source_security_group_id = aws_security_group.internet_proxy_endpoint.id
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "ingress_k2hb_main_to_internet" {
  description              = "Allow k2hb access to Internet Proxy (for ACM-PCA)"
  type                     = "ingress"
  source_security_group_id = aws_security_group.k2hb_main.id
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = aws_security_group.internet_proxy_endpoint.id
}

resource "aws_security_group_rule" "k2hb_main_to_dns_name_servers_tcp" {
  count             = local.peer_with_ucfs[local.environment] ? 1 : 0
  description       = "Allow consumers to reach ucfs DNS name servers"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_dns_name_servers_udp" {
  count             = local.peer_with_ucfs[local.environment] ? 1 : 0
  description       = "Allow consumers to reach ucfs DNS name servers"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = local.ucfs_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_ucfs_london_dns_tcp" {
  count             = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  description       = "Allow consumers to reach UCFS DNS (London)"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_london_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_to_ucfs_london_dns_udp" {
  count             = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  description       = "Allow consumers to reach UCFS DNS (London)"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = local.ucfs_london_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_master_zookeeper" {
  description              = "Allow outbound requests to HBase zookeeper"
  type                     = "egress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_master.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_master_16000" {
  description              = "Allow outbound requests to HBase master"
  type                     = "egress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_master.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_master_16020" {
  description              = "Allow outbound requests to HBase master"
  type                     = "egress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_master.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_master_16030" {
  description              = "Allow outbound requests to HBase master"
  type                     = "egress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_master.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_servers_16000" {
  description              = "Allow outbound requests to HBase servers"
  type                     = "egress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_slave.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_servers_16020" {
  description              = "Allow outbound requests to HBase servers"
  type                     = "egress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_slave.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_emr_sservers_16030" {
  description              = "Allow outbound reqests to HBase servers"
  type                     = "egress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_hbase_slave.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "k2hb_main_egress_metadata_store" {
  description              = "Allow outbound requests to Metadata Store DB"
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.metadata_store.id
  security_group_id        = aws_security_group.k2hb_main.id
}

resource "aws_security_group_rule" "metadata_store_from_k2hb_ec2_main" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.metadata_store.id
  description              = "Metadata store from K2HB ec2"
}

# Current log group as-at Aug 2020. Do not change the resource name or logical name
resource "aws_cloudwatch_log_group" "k2hb_ec2_logs" {
  name              = "/aws/ec2/main/k2hb"
  retention_in_days = 180
  tags              = local.common_tags
}

# Old ECS log group - left as CI can't delete it. DW-4728 to remove
resource "aws_cloudwatch_log_group" "k2hb_logs" {
  name              = "/aws/ecs/main/k2hb"
  retention_in_days = 180
  tags              = local.common_tags
}

# Old ECS log group - left as CI can't delete it. DW-4728 to remove
resource "aws_cloudwatch_log_group" "k2h_consumer_logs" {
  name              = "/aws/ecs/main/kafka-to-hbase-consumer"
  retention_in_days = 180
  tags              = local.common_tags
}

# These are the security group rules for the EMR connection from this k2hb
resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_master_zookeeper" {
  description              = "Allow all inbound zookeeper requests from k2hb main"
  type                     = "ingress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_master.id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_master_16000" {
  description              = "Allow all inbound HBase Region Server requests from k2hb main"
  type                     = "ingress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_master.id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_master_16020" {
  description              = "Allow all inbound HBase Region Server requests from k2hb main"
  type                     = "ingress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_master.id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_master_16030" {
  description              = "Allow all inbound HBase Region Server requests from k2hb main"
  type                     = "ingress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_master.id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_servers_16000" {
  description              = "Allow all inbound HBase Master requests from k2hb main"
  type                     = "ingress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_slave.id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_servers_16020" {
  description              = "Allow all inbound HBase Master requests from k2hb main"
  type                     = "ingress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_slave.id
}

resource "aws_security_group_rule" "emr_server_ingress_k2hb_main_servers_16030" {
  description              = "Allow all inbound HBase Master requests from k2hb main"
  type                     = "ingress"
  from_port                = 16030
  to_port                  = 16030
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_main.id
  security_group_id        = aws_security_group.emr_hbase_slave.id
}
