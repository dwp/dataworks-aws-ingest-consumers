locals {
  k2hb_main_tags_asg = merge(
    local.common_tags,
    {
      Name         = "${local.k2hb_main_consumer_name}-${local.environment}",
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
  vpc_security_group_ids = [aws_security_group.k2hb_common.id]

  user_data = base64encode(templatefile("k2hb_userdata.tpl", {
    environment_name          = local.environment
    k2hb_version              = var.k2hb_version
    k2hb_application_name     = local.k2hb_main_consumer_name
    k2hb_kafka_consumer_group = local.k2hb_kafka_main_consumer_group //different server to old single node broker, so keep the same name
    k2hb_log_level            = local.k2hb_log_level[local.environment]

    k2hb_kafka_bootstrap_servers = join(
      ",",
      formatlist(
        "%s:%s",
        data.terraform_remote_state.ingest.outputs.locals.kafka_bootstrap_servers[local.environment],
        data.terraform_remote_state.ingest.outputs.locals.kafka_broker_port[local.environment],
      ),
    )

    acm_cert_arn          = data.terraform_remote_state.ingest.outputs.k2hb_cert.arn
    private_key_alias     = "k2hb"
    truststore_aliases    = local.kafka_consumer_truststore_aliases[local.environment]
    truststore_certs      = local.kafka_consumer_truststore_certs[local.environment]
    internet_proxy        = data.terraform_remote_state.ingest.outputs.internet_proxy.host
    non_proxied_endpoints = join(",", data.terraform_remote_state.ingest.outputs.vpc.vpc.no_proxy_list)
    s3_artefact_bucket_id = data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id

    hbase_master_url                                 = data.terraform_remote_state.ingest.outputs.aws_emr_cluster.fqdn
    k2hb_max_memory_allocation                       = var.k2hb_main_max_memory_allocation[local.environment]
    cwa_metrics_collection_interval                  = local.cw_agent_metrics_collection_interval
    cwa_namespace                                    = local.cw_k2hb_agent_namespace
    cwa_cpu_metrics_collection_interval              = local.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = local.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = local.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = local.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = local.cw_agent_netstat_metrics_collection_interval
    cwa_log_group_name                               = data.terraform_remote_state.ingest.outputs.log_groups.k2hb_ec2_logs.name
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
    k2hb_rds_table_name                              = data.terraform_remote_state.ingest.outputs.metadata_store_table_names.ucfs
    k2hb_rds_endpoint                                = data.terraform_remote_state.ingest.outputs.metadata_store.rds.endpoint
    k2hb_rds_port                                    = data.terraform_remote_state.ingest.outputs.metadata_store.rds.port
    k2hb_kafka_topic_regex                           = local.kafka_consumer_main_topics_regex[local.environment]
    k2hb_kafka_meta_refresh_ms                       = local.kafka_k2hb_meta_refresh_ms[local.environment]
    k2hb_kafka_max_poll_interval_ms                  = local.k2hb_max_poll_interval_ms[local.environment]
    k2hb_kafka_poll_timeout                          = local.kafka_k2hb_poll_timeout[local.environment]
    k2hb_kafka_insecure                              = "false"
    k2hb_kafka_cert_mode                             = "RETRIEVE"
    k2hb_kafka_dlq_topic                             = local.dlq_kafka_consumer_topic
    k2hb_kafka_poll_max_records                      = local.k2hb_max_poll_records_count_main[local.environment]
    k2hb_kafka_report_frequency                      = local.k2hb_report_frequency[local.environment]
    k2hb_qualified_table_pattern                     = local.k2hb_main_data_qualified_table_pattern
    k2hb_check_existence                             = local.k2hb_check_existence[local.environment]
    k2hb_aws_s3_archive_bucket                       = local.k2hb_aws_s3_archive_bucket_id
    k2hb_aws_s3_archive_directory                    = local.k2hb_aws_s3_main_archive_directory
    k2hb_aws_s3_batch_puts                           = "true"
    k2hb_validator_schema                            = local.k2hb_validator_schema.ucfs
    k2hb_write_to_metadata_store                     = local.k2hb_main_ha_write_to_metadata_store[local.environment]
    k2hb_manifest_bucket                             = data.terraform_remote_state.internal_compute.outputs.manifest_bucket.id
    k2hb_manifest_prefix                             = data.terraform_remote_state.ingest.outputs.k2hb_manifest_write_locations.main_prefix
    k2hb_write_manifests                             = local.k2hb_main_write_manifests[local.environment]
    k2hb_auto_commit_metadata_store_inserts          = local.k2hb_main_auto_commit_metadata_store_inserts[local.environment]
  }))

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = aws_iam_instance_profile.k2hb_common.arn
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
      Name        = local.k2hb_main_consumer_name,
      Persistence = "Ignore"
    },
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name        = local.k2hb_main_consumer_name,
        Application = local.k2hb_main_consumer_name,
        Persistence = "Ignore"
      },
    )
  }
}

resource "aws_autoscaling_group" "k2hb_main_ha_cluster" {
  name_prefix               = "${aws_launch_template.k2hb_main_ha_cluster.name}-lt_ver${aws_launch_template.k2hb_main_ha_cluster.latest_version}_"
  min_size                  = local.k2hb_asg_min[local.environment]
  desired_capacity          = var.k2hb_main_asg_desired[local.environment]
  max_size                  = var.k2hb_main_asg_max[local.environment]
  health_check_grace_period = 600
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = data.terraform_remote_state.ingest.outputs.ingestion_subnets.id

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
