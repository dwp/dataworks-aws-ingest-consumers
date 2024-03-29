# London

# A dedicated stack of consumers for the top few busiest topics.

locals {
  k2hb_main_dedicated_london_tags_asg = merge(
    local.k2hb_main_tags_asg,
    {
      Name     = "k2hb-main-dedicated-london",
      Location = "London",
    }
  )
}

resource "aws_launch_template" "k2hb_main_dedicated_london" {
  name                   = "k2hb_london_dedicated_main"
  image_id               = var.al2_hardened_ami_id
  instance_type          = var.k2hb_main_ec2_size[local.environment]
  vpc_security_group_ids = [aws_security_group.k2hb_common.id]

  user_data = base64encode(templatefile("k2hb_userdata.tpl", {
    environment_name          = "${local.environment}-dedicated-london"
    k2hb_version              = var.k2hb_version
    k2hb_application_name     = local.k2hb_main_consumer_name
    k2hb_kafka_consumer_group = local.k2hb_kafka_main_consumer_group
    k2hb_log_level            = local.k2hb_log_level[local.environment]
    name                      = "k2hb-main-dedicated-london"

    k2hb_kafka_bootstrap_servers = join(
      ",",
      formatlist(
        "%s:%s",
        local.kafka_london_bootstrap_servers[local.environment],
        local.kafka_broker_port[local.environment],
      ),
    )

    acm_cert_arn          = local.ingest_k2hb_cert_arn
    private_key_alias     = "k2hb"
    truststore_aliases    = local.kafka_consumer_truststore_aliases[local.environment]
    truststore_certs      = local.kafka_consumer_truststore_certs[local.environment]
    internet_proxy        = local.ingest_internet_proxy.host
    non_proxied_endpoints = join(",", local.ingest_no_proxy_list)
    s3_artefact_bucket_id = local.managemant_artefact_bucket.id
    proxy_host            = local.ingest_internet_proxy.host
    proxy_port            = var.proxy_port
    hcs_environment       = local.hcs_environment[local.environment]
    install_tenable       = local.tenable_install[local.environment]
    install_trend         = local.trend_install[local.environment]
    install_tanium        = local.tanium_install[local.environment]
    tanium_server_1       = data.terraform_remote_state.ingest.outputs.tanium_service_endpoint.dns
    tanium_server_2       = local.tanium2
    tanium_env            = local.tanium_env[local.environment]
    tanium_port           = var.tanium_port_1
    tanium_log_level      = local.tanium_log_level[local.environment]
    tenant                = local.tenant
    tenantid              = local.tenantid
    token                 = local.token
    policyid              = local.policy_id[local.environment]

    hbase_master_url                                 = local.ingest_hbase_fqdn
    k2hb_max_memory_allocation                       = var.k2hb_main_max_memory_allocation[local.environment]
    cwa_metrics_collection_interval                  = local.cw_agent_metrics_collection_interval
    cwa_namespace                                    = local.cw_k2hb_main_agent_namespace
    cwa_cpu_metrics_collection_interval              = local.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = local.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = local.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = local.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = local.cw_agent_netstat_metrics_collection_interval
    cwa_log_group_name                               = local.ingest_log_groups.k2hb_ec2_logs.name
    s3_scripts_bucket                                = local.common_config_bucket.id
    s3_script_key_k2hb_sh                            = aws_s3_bucket_object.k2hb_shell_script.id
    s3_script_key_k2hb_init                          = aws_s3_bucket_object.k2hb_init_script.id
    s3_script_key_k2hb_logrotate                     = aws_s3_bucket_object.k2hb_logrotate_script.id
    s3_script_k2hb_cloudwatch_sh                     = aws_s3_bucket_object.k2hb_cloudwatch_script.id
    s3_script_common_logging_sh                      = local.common_logging_file.s3_id
    s3_script_logging_sh                             = aws_s3_bucket_object.logging_script.id
    s3_script_respawn_k2hb_sh                        = aws_s3_bucket_object.respawn_k2hb_script.id
    s3_script_config_hcs_sh                          = aws_s3_bucket_object.config_hcs.id
    s3_script_amazon_root_ca1_pem                    = aws_s3_bucket_object.amazon_root_ca1_pem.id
    s3_script_hash_k2hb_sh                           = md5(data.local_file.k2hb_shell_script.content)
    s3_script_hash_k2hb_init                         = md5(data.local_file.k2hb_init_script.content)
    s3_script_hash_k2hb_logrotate                    = md5(data.local_file.k2hb_logrotate_script.content)
    s3_script_hash_k2hb_cloudwatch_sh                = md5(data.local_file.k2hb_cloudwatch_script.content)
    s3_script_hash_common_logging_sh                 = local.common_logging_file.hash
    s3_script_hash_logging_sh                        = md5(data.local_file.logging_script.content)
    s3_script_hash_respawn_k2hb_sh                   = md5(data.local_file.respawn_k2hb_script.content)
    s3_script_hash_amazon_root_ca1_pem               = md5(data.local_file.amazon_root_ca1_pem.content)
    s3_script_hash_config_hcs_sh                     = md5(data.local_file.config_hcs.content)
    k2hb_hbase_zookeeper_parent                      = "/hbase"
    k2hb_hbase_zookeeper_quorum                      = local.ingest_hbase_fqdn
    k2hb_hbase_zookeeper_port                        = "2181"
    k2hb_hbase_data_family                           = local.k2hb_data_family
    k2hb_hbase_data_qualifier                        = local.k2hb_data_qualifier
    k2hb_hbase_log_keys                              = local.k2hb_output_hbase_keys[local.environment]
    k2hb_hbase_region_replication                    = local.k2hb_hbase_region_replication[local.environment]
    k2hb_hbase_rpc_timeout_milliseconds              = local.kafka_k2hb_hbase_rpc_timeout_milliseconds[local.environment]
    k2hb_hbase_client_operation_timeout_milliseconds = local.kafka_k2hb_hbase_client_operation_timeout_milliseconds[local.environment]
    k2hb_hbase_pause_milliseconds                    = local.kafka_k2hb_hbase_client_pause_milliseconds[local.environment]
    k2hb_hbase_retries                               = local.kafka_k2hb_hbase_client_retries[local.environment]
    k2hb_retry_max_attempts                          = local.kafka_k2hb_hbase_retry_attempts[local.environment]
    k2hb_use_aws_secrets                             = "true"
    k2hb_rds_username                                = local.ingest_metadata_store.credentials.metadata_store_k2hbwriter_username
    k2hb_rds_password_secret_name                    = local.ingest_metadata_store.credentials.metadata_store_k2hbwriter.name
    k2hb_rds_database_name                           = local.ingest_metadata_store.rds.database_name
    k2hb_rds_table_name                              = local.ingest_metadata_store_table_names.ucfs
    k2hb_rds_endpoint                                = local.ingest_metadata_store.rds.endpoint
    k2hb_rds_port                                    = local.ingest_metadata_store.rds.port
    k2hb_kafka_topic_regex                           = local.kafka_consumer_main_dedicated_topics_regex[local.environment]
    k2hb_kafka_topic_exclusion_regex                 = "" // this stack has no exclusions
    k2hb_kafka_meta_refresh_ms                       = local.kafka_k2hb_meta_refresh_ms[local.environment]
    k2hb_kafka_max_poll_interval_ms                  = local.k2hb_max_poll_interval_ms[local.environment]
    k2hb_kafka_poll_timeout                          = local.kafka_k2hb_poll_timeout[local.environment]
    k2hb_kafka_insecure                              = "false"
    k2hb_kafka_cert_mode                             = "RETRIEVE"
    k2hb_kafka_dlq_topic                             = local.dlq_kafka_consumer_topic
    k2hb_kafka_poll_max_records                      = local.k2hb_main_max_poll_records_count[local.environment]
    k2hb_kafka_report_frequency                      = local.k2hb_report_frequency[local.environment]
    k2hb_qualified_table_pattern                     = local.k2hb_main_data_qualified_table_pattern
    k2hb_check_existence                             = local.k2hb_check_existence[local.environment]
    k2hb_aws_s3_archive_bucket                       = local.k2hb_aws_s3_archive_bucket_id
    k2hb_aws_s3_archive_directory                    = local.k2hb_aws_s3_main_archive_directory
    k2hb_aws_s3_batch_puts                           = "true"
    k2hb_validator_schema                            = local.k2hb_validator_schema.ucfs
    k2hb_write_to_metadata_store                     = local.k2hb_main_write_to_metadata_store[local.environment]
    k2hb_manifest_bucket                             = local.internal_compute_manifest_bucket.id
    k2hb_manifest_prefix                             = local.ingest_manifest_write_locations.main_prefix
    k2hb_write_manifests                             = local.k2hb_main_write_manifests[local.environment]
    k2hb_auto_commit_metadata_store_inserts          = local.k2hb_main_auto_commit_metadata_store_inserts[local.environment]
    k2hb_kafka_max_fetch_bytes                       = local.k2hb_main_kafka_max_fetch_bytes[local.environment]
    k2hb_kafka_max_partition_fetch_bytes             = local.k2hb_main_kafka_max_partition_fetch_bytes[local.environment]
    k2hb_hbase_bypass_topics                         = "" // Write all topics to HBase
    k2hb_pushgateway_hostname                        = local.ingest_pushgateway_hostname
    k2hb_kafka_fetch_min_bytes                       = local.k2hb_main_kafka_fetch_min_bytes[local.environment]
    k2hb_kafka_fetch_max_wait_ms                     = local.k2hb_main_kafka_fetch_max_wait_ms[local.environment]
    k2hb_kafka_consumer_request_timeout_ms           = local.k2hb_main_kafka_consumer_request_timeout_ms[local.environment]
  }))

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = aws_iam_instance_profile.k2hb_common.arn
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = local.k2hb_main_dedicated_ebs_size[local.environment]
      volume_type           = local.k2hb_main_dedicated_ebs_type[local.environment]
      delete_on_termination = true
      encrypted             = true
    }
  }

  tags = local.k2hb_main_dedicated_london_tags_asg

  tag_specifications {
    resource_type = "instance"
    tags          = local.k2hb_main_dedicated_london_tags_asg
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.k2hb_main_dedicated_london_tags_asg
  }
}

resource "aws_autoscaling_group" "k2hb_main_dedicated_london" {
  name_prefix               = "${aws_launch_template.k2hb_main_dedicated_london.name}-lt_ver${aws_launch_template.k2hb_main_dedicated_london.latest_version}_"
  min_size                  = local.k2hb_asg_min[local.environment]
  desired_capacity          = var.k2hb_main_dedicated_london_asg_desired[local.environment]
  max_size                  = var.k2hb_main_dedicated_london_asg_max[local.environment]
  health_check_grace_period = 600
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = local.ingest_subnets.id
  enabled_metrics           = local.k2hb_asg_enabled_metrics
  metrics_granularity       = "1Minute"

  launch_template {
    id      = aws_launch_template.k2hb_main_dedicated_london.id
    version = "$Latest"
  }

  tags = [
    for key, value in local.k2hb_main_dedicated_london_tags_asg :
    {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  ]

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
