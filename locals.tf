locals {
  env_prefix = {
    development = "dev."
    qa          = "qa."
    stage       = "stg."
    integration = "int."
    preprod     = "pre."
    production  = ""
  }

  iam_role_max_session_timeout_seconds = 43200

  k2hb_main_consumer_name     = "k2hb-main-ha-cluster"
  k2hb_s3only_consumer_name   = "k2hb-s3only"
  k2hb_equality_consumer_name = "k2hb-equality"
  k2hb_audit_consumer_name    = "k2hb-audit"

  k2hb_main_asg_autoshutdown = {
    development = "False"
    qa          = "False"
    integration = "False"
    preprod     = "False"
    production  = "False"
  }

  k2hb_main_asg_ssmenabled = {
    development = "True"
    qa          = "True"
    integration = "True"
    preprod     = "False"
    production  = "False"
  }

  k2hb_main_asg_inspector = {
    development = "disabled"
    qa          = "disabled"
    integration = "disabled"
    preprod     = "disabled"
    production  = "disabled"
  }

  k2hb_equality_asg_autoshutdown = {
    development = "False"
    qa          = "False"
    integration = "False"
    preprod     = "False"
    production  = "False"
  }

  k2hb_equality_asg_ssmenabled = {
    development = "True"
    qa          = "True"
    integration = "True"
    preprod     = "False"
    production  = "False"
  }

  k2hb_equality_asg_inspector = {
    development = "disabled"
    qa          = "disabled"
    integration = "disabled"
    preprod     = "disabled"
    production  = "disabled"
  }

  k2hb_audit_asg_autoshutdown = {
    development = "False"
    qa          = "False"
    integration = "False"
    preprod     = "False"
    production  = "False"
  }

  k2hb_audit_asg_ssmenabled = {
    development = "True"
    qa          = "True"
    integration = "True"
    preprod     = "False"
    production  = "False"
  }

  k2hb_audit_asg_inspector = {
    development = "disabled"
    qa          = "disabled"
    integration = "disabled"
    preprod     = "disabled"
    production  = "disabled"
  }

  // Common across all k2hb ASGs. Minimum k2hb asg size. Should always be zero to allow us to scale at will for releases and tests.
  k2hb_asg_min = {
    development = 0
    qa          = 0
    integration = 0
    preprod     = 0
    production  = 0
  }

  k2hb_log_level = {
    development = "DEBUG"
    qa          = "INFO"
    integration = "INFO"
    preprod     = "INFO"
    production  = "INFO"
  }

  k2hb_hbase_region_replication = {
    development = "3"
    qa          = "3"
    integration = "3"
    preprod     = "3"
    production  = "3"
  }

  k2hb_report_frequency = {
    development = "10"
    qa          = "10"
    integration = "100"
    preprod     = "10"
    production  = "100"
  }

  k2hb_output_hbase_keys = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "true"
    production  = "true"
  }

  k2hb_main_write_manifests = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  k2hb_equality_write_manifests = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  k2hb_audit_write_manifests = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  k2hb_main_auto_commit_metadata_store_inserts = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  k2hb_equality_auto_commit_metadata_store_inserts = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  k2hb_audit_auto_commit_metadata_store_inserts = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  k2hb_main_kafka_max_fetch_bytes = {
    development = 20000000
    qa          = 20000000
    integration = 20000000
    preprod     = 20000000
    production  = 20000000
  }

  k2hb_equality_kafka_max_fetch_bytes = {
    development = 20000000
    qa          = 20000000
    integration = 20000000
    preprod     = 20000000
    production  = 20000000
  }

  k2hb_audit_kafka_max_fetch_bytes = {
    # ~128MB
    development = 128000000
    qa          = 128000000
    integration = 128000000
    preprod     = 128000000
    production  = 128000000
  }

  k2hb_kafka_fetch_min_bytes = {
    # ~10MB
    development = 10000000
    qa          = 10000000
    integration = 10000000
    preprod     = 10000000
    production  = 10000000
  }

  k2hb_main_kafka_max_partition_fetch_bytes = {
    development = 20000000
    qa          = 20000000
    integration = 20000000
    preprod     = 20000000
    production  = 20000000
  }

  k2hb_equality_kafka_max_partition_fetch_bytes = {
    development = 20000000
    qa          = 20000000
    integration = 20000000
    preprod     = 20000000
    production  = 20000000
  }

  k2hb_audit_kafka_max_partition_fetch_bytes = {
    development = 20000000
    qa          = 20000000
    integration = 20000000
    preprod     = 20000000
    production  = 20000000
  }

  k2hb_kafka_fetch_max_wait_ms = {
    # ~60s
    development = 60000
    qa          = 60000
    integration = 60000
    preprod     = 60000
    production  = 60000
  }

  k2hb_main_corporate_storage_coalesce_max_files = {
    development = 1000000
    qa          = 1000000
    integration = 1000000
    preprod     = 1000000
    production  = 1000000
  }

  k2hb_equalities_corporate_storage_coalesce_max_files = {
    development = 1000000
    qa          = 1000000
    integration = 1000000
    preprod     = 1000000
    production  = 1000000
  }

  k2hb_audit_corporate_storage_coalesce_max_files = {
    development = 1000000
    qa          = 1000000
    integration = 1000000
    preprod     = 1000000
    production  = 1000000
  }

  k2hb_main_corporate_storage_coalesce_max_size_bytes = {
    development = 128000000
    qa          = 128000000
    integration = 128000000
    preprod     = 128000000
    production  = 128000000
  }

  k2hb_equalities_corporate_storage_coalesce_max_size_bytes = {
    development = 128000000
    qa          = 128000000
    integration = 128000000
    preprod     = 128000000
    production  = 128000000
  }

  k2hb_audit_corporate_storage_coalesce_max_size_bytes = {
    development = 128000000
    qa          = 128000000
    integration = 128000000
    preprod     = 128000000
    production  = 128000000
  }

  k2hb_kafka_main_consumer_group     = "dataworks-ucfs-kafka-to-hbase-ingest-${local.environment}"
  k2hb_kafka_equality_consumer_group = "dataworks-ucfs-kafka-equality-to-hbase-ingest-${local.environment}"
  k2hb_kafka_audit_consumer_group    = "dataworks-ucfs-kafka-audit-to-hbase-ingest-${local.environment}"

  kafka_consumer_truststore_aliases = {
    development = "ucfs_ca"
    qa          = "ucfs_ca"
    integration = "ucfs_ca"
    preprod     = "ucfs_ca"
    production  = "ucfs_ca,ucfs_ca_old"
  }

  kafka_consumer_truststore_certs = {
    development = "s3://${local.certificate_auth_public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    qa          = "s3://${local.certificate_auth_public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    integration = "s3://${local.certificate_auth_public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    preprod     = "s3://${local.certificate_auth_public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    production  = "s3://${local.certificate_auth_public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem,s3://${local.certificate_auth_public_cert_bucket.id}/ca_certificates/ucfs/root_ca_old.pem"
  }

  cw_k2hb_main_agent_namespace                          = "/app/kafka-to-hbase"
  cw_k2hb_equality_agent_namespace                      = "/app/kafka-to-hbase-equality"
  cw_k2hb_audit_agent_namespace                         = "/app/kafka-to-hbase-audit"
  cw_k2hb_s3only_agent_namespace                        = "/app/kafka-to-hbase-s3only"
  cw_agent_metrics_collection_interval                  = 60
  cw_agent_cpu_metrics_collection_interval              = 60
  cw_agent_disk_measurement_metrics_collection_interval = 60
  cw_agent_disk_io_metrics_collection_interval          = 60
  cw_agent_mem_metrics_collection_interval              = 60
  cw_agent_netstat_metrics_collection_interval          = 60

  k2hb_data_family    = "cf"
  k2hb_data_qualifier = "record"

  # These should be in ISO-8601 duration format, see https://en.wikipedia.org/wiki/ISO_8601
  # The poll timeout is the longest time we will wait for talking to the downstream system (i.e. hbase) before
  # we give up
  kafka_k2hb_poll_timeout = {
    development = "PT5M"
    qa          = "PT5M"
    integration = "PT5M"
    preprod     = "PT20M"
    production  = "PT20M"
  }

  # This is how often we promise to talk to the kafka broker so we do not get kicked out of the consumer group
  # This should be greater than the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_max_poll_interval_ms = {
    development = 600000
    qa          = 600000
    integration = 600000
    preprod     = 1800000
    production  = 1800000
  }

  # This should be the number of records we can easily process within the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_main_max_poll_records_count = {
    development = 25
    qa          = 50
    integration = 50
    preprod     = 5000
    production  = 5000
  }

  # This should be the number of records we can easily process within the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_equality_max_poll_records_count = {
    development = 25
    qa          = 50
    integration = 50
    preprod     = 1000
    production  = 1000
  }

  # This should be the number of records we can easily process within the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_audit_max_poll_records_count = {
    development = 25
    qa          = 50
    integration = 50
    preprod     = 2000
    production  = 2000
  }

  # Enable this to verify puts with exists checks
  k2hb_check_existence = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  # Total time for the client to process one RPC request before closing the connection
  kafka_k2hb_hbase_rpc_timeout_milliseconds = {
    development = "60000"
    qa          = "60000"
    integration = "60000"
    preprod     = "90000"
    production  = "90000"
  }

  # Total time for the client to process a full data scenario before closing the connection
  kafka_k2hb_hbase_client_operation_timeout_milliseconds = {
    development = "90000"
    qa          = "90000"
    integration = "90000"
    preprod     = "90000"
    production  = "90000"
  }

  # Retries for K2HB itself to try HBase operations
  kafka_k2hb_hbase_retry_attempts = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "1"
    production  = "1"
  }

  # Milliseconds between retries in the hbase client
  kafka_k2hb_hbase_client_pause_milliseconds = {
    development = "100"
    qa          = "100"
    integration = "100"
    preprod     = "100"
    production  = "100"
  }

  # Number of retries in the hbase client
  kafka_k2hb_hbase_client_retries = {
    development = "35"
    qa          = "35"
    integration = "35"
    preprod     = "35"
    production  = "35"
  }

  kafka_k2hb_meta_refresh_ms = {
    development = "10000"
    qa          = "10000"
    integration = "10000"
    preprod     = "100000"
    production  = "100000"
  }

  // DW-4748 & DW-4827 - Allow extra dot in last matcher group for db.crypto.encryptedData.unencrypted
  k2hb_main_data_qualified_table_pattern = "^\\w+\\.([-\\w]+)\\.([-.\\w]+)$"
  // Only needs to work for exactly "data.equality"
  k2hb_data_equality_qualified_table_pattern = "^([-\\w]+)\\.([-\\w]+)$"
  // Only needs to work for exactly "data.businessAudit"
  k2hb_data_audit_qualified_table_pattern = "^([-\\w]+)\\.([-\\w]+)$"

  k2hb_validator_schema = {
    ucfs     = "business_message.schema.json" //this is the default if not specified, version 0.0.153++
    equality = "equality_message.schema.json"
    audit    = "audit_message.schema.json"
  }

  k2hb_main_write_to_metadata_store = {
    development = true
    qa          = true
    integration = false # Not used in this environment
    preprod     = false # Not used in this environment
    production  = false # Will run ad-hoc as and when needed
  }

  k2hb_equality_write_to_metadata_store = {
    development = true
    qa          = true
    integration = false # Not used in this environment
    preprod     = false # Not used in this environment
    production  = true
  }

  k2hb_audit_write_to_metadata_store = {
    development = true
    qa          = true
    integration = false # Not used in this environment
    preprod     = false # Not used in this environment
    production  = false # Will run ad-hoc as and when needed
  }

  k2hb_metric_name_number_of_successfully_processed_batches = "The number of batches successfully processed"
  k2hb_metric_name_number_of_successfully_processed_records = "The number of records successfully processed"
  k2hb_metric_name_speed_of_successfully_processed_batches  = "The speed of successfully process batches"
  k2hb_metric_name_messages_written_to_dlq                  = "Number of messages being written to DLQ"
  k2hb_metric_name_timeouts_reading_kafka                   = "Number of timeout occurrences when reading from Kafka exceeds threshold"
  k2hb_metric_name_failures_writing_hbase                   = "Number of errors writing to Hbase"
  k2hb_metric_name_timeouts_connecting_hbase                = "Number of timeout occurrences when connecting to Hbase exceeds threshold"
  k2hb_metric_name_lag_per_partition                        = "Consumer lag (records todo) per partition"
  k2hb_metric_name_failed_batches                           = "Number of failed batches"

  hbase_emr_ports = [
    {
      name : "HBase zookeeper"
      port : 2181
    },
    {
      name : "HBase master"
      port : 16000
    },
    {
      name : "HBase RegionServer"
      port : 16020
    },
    {
      name : "HBase RegionServer Info"
      port : 16030
    },
  ]

  #### Import lots of the things we need from dip/aws-ingest in one place to make our tf cleaner in this repo ####
  k2hb_aws_s3_archive_bucket_id          = data.terraform_remote_state.ingest.outputs.corporate_storage_bucket.id
  k2hb_aws_s3_main_archive_directory     = "${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_directory_prefix}/${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_bucket_directory.ucfs_main}"
  k2hb_aws_s3_equality_archive_directory = "${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_directory_prefix}/${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_bucket_directory.ucfs_equality}"
  k2hb_aws_s3_audit_archive_directory    = "${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_directory_prefix}/${data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_bucket_directory.ucfs_audit}"

  managemant_artefact_bucket = data.terraform_remote_state.management_artefact.outputs.artefact_bucket

  ingest_internet_proxy                     = data.terraform_remote_state.ingest.outputs.internet_proxy
  ingest_metadata_store                     = data.terraform_remote_state.ingest.outputs.metadata_store
  ingest_metadata_store_table_names         = data.terraform_remote_state.ingest.outputs.metadata_store_table_names
  ingest_corporate_storage_directory_prefix = data.terraform_remote_state.ingest.outputs.corporate_storage.corporate_storage_directory_prefix
  ingest_corporate_storage_bucket           = data.terraform_remote_state.ingest.outputs.corporate_storage_bucket
  ingest_k2hb_cert_arn                      = data.terraform_remote_state.ingest.outputs.k2hb_cert.arn
  ingest_no_proxy_list                      = data.terraform_remote_state.ingest.outputs.vpc.vpc.no_proxy_list
  ingest_manifest_write_locations           = data.terraform_remote_state.ingest.outputs.k2hb_manifest_write_locations
  ingest_storage_write_locations            = data.terraform_remote_state.ingest.outputs.corporate_data_loader
  ingest_subnets                            = data.terraform_remote_state.ingest.outputs.ingestion_subnets
  ingest_log_groups                         = data.terraform_remote_state.ingest.outputs.log_groups
  ingest_vpc_interface_vpce_sg_id           = data.terraform_remote_state.ingest.outputs.vpc.vpc.interface_vpce_sg_id
  ingest_vpc_prefix_list_ids_s3             = data.terraform_remote_state.ingest.outputs.vpc.vpc.prefix_list_ids.s3
  ingest_vpc_ecr_dkr_domain_name            = data.terraform_remote_state.ingest.outputs.vpc.vpc.ecr_dkr_domain_name
  ingest_input_bucket_cmk_arn               = data.terraform_remote_state.ingest.outputs.input_bucket_cmk.arn
  ingest_input_bucket_arn                   = data.terraform_remote_state.ingest.outputs.s3_input_bucket_arn.input_bucket
  ingest_vpc_id                             = data.terraform_remote_state.ingest.outputs.vpc.vpc.vpc.id

  ingest_pushgateway_hostname = "${data.terraform_remote_state.ingest.outputs.private_dns.ingest_service_discovery.name}.${data.terraform_remote_state.ingest.outputs.private_dns.ingest_service_discovery_dns.name}"

  ingest_hbase_fqdn             = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.fqdn
  ingest_hbase_emr_common_sg_id = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.common_sg_id

  internal_compute_manifest_bucket     = data.terraform_remote_state.internal_compute.outputs.manifest_bucket
  internal_compute_manifest_bucket_cmk = data.terraform_remote_state.internal_compute.outputs.manifest_bucket_cmk

  common_config_bucket         = data.terraform_remote_state.common.outputs.config_bucket
  common_config_bucket_cmk_arn = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  common_logging_file          = data.terraform_remote_state.common.outputs.application_logging_common_file

  certificate_auth_public_cert_bucket = data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket
  certificate_auth_root_ca_arn        = data.terraform_remote_state.certificate_authority.outputs.root_ca.arn

  security_tools_ebs_cmk_arn = data.terraform_remote_state.security-tools.outputs.ebs_cmk.arn

  monitoring_topic_arn = data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn

  stub_kafka_broker_port_https = data.terraform_remote_state.ingest.outputs.locals.stub_kafka_broker_port_https
  stub_bootstrap_servers       = data.terraform_remote_state.ingest.outputs.locals.stub_bootstrap_servers
  stub_ucfs_subnets            = data.terraform_remote_state.ingest.outputs.stub_ucfs_subnets
  stub_ucfs_deploy_broker      = data.terraform_remote_state.ingest.outputs.stub_ucfs.deploy_stub_broker
  stub_ucfs_kafka_ports        = data.terraform_remote_state.ingest.outputs.stub_ucfs.stub_ucfs_kafka_ports
  stub_ucfs_sg_id              = data.terraform_remote_state.ingest.outputs.stub_ucfs.sg_id

  uc_kafka_broker_port_https = data.terraform_remote_state.ingest.outputs.locals.uc_kafka_broker_port_https
  dlq_kafka_consumer_topic   = data.terraform_remote_state.ingest.outputs.locals.dlq_kafka_consumer_topic // must match what k2s3 uses

  // All of the following block is TOP SECRET, and must come from DIP or AWS Secrets via Bootstrap
  ucfs_broker_cidr_blocks             = data.terraform_remote_state.ingest.outputs.locals.ucfs_broker_cidr_blocks
  ucfs_london_broker_cidr_blocks      = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_broker_cidr_blocks
  ucfs_nameservers_cidr_blocks        = data.terraform_remote_state.ingest.outputs.locals.ucfs_nameservers_cidr_blocks
  ucfs_london_nameservers_cidr_blocks = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_nameservers_cidr_blocks

  // All of the following block is SENSITIVE, and must come from DIP or AWS Secrets via Bootstrap
  ucfs_ha_broker_prefix   = data.terraform_remote_state.ingest.outputs.locals.ucfs_ha_broker_prefix
  ucfs_domains            = data.terraform_remote_state.ingest.outputs.locals.ucfs_domains
  ucfs_london_domains     = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_domains
  ucfs_nameservers        = data.terraform_remote_state.ingest.outputs.locals.ucfs_nameservers
  ucfs_london_nameservers = data.terraform_remote_state.ingest.outputs.locals.ucfs_london_nameservers

  k2hb_data_source_is_ucfs = data.terraform_remote_state.ingest.outputs.locals.k2hb_data_source_is_ucfs
  peer_with_ucfs_london    = data.terraform_remote_state.ingest.outputs.locals.peer_with_ucfs_london

  k2hb_ec2_business_logs_name = local.ingest_log_groups.k2hb_ec2_logs.name
  k2hb_ec2_equality_logs_name = local.ingest_log_groups.k2hb_ec2_equality_logs.name
  k2hb_ec2_audit_logs_name    = "/aws/ec2/main/k2hb_audit"
  k2hb_ec2_s3only_logs_name   = "/aws/ec2/main/k2hb_s3only"

  ## Calculate all the things based on the imports from aws-ingest ##

  kafka_broker_port = {
    development = local.stub_kafka_broker_port_https
    qa          = local.stub_kafka_broker_port_https
    integration = local.k2hb_data_source_is_ucfs[local.environment] ? local.uc_kafka_broker_port_https : local.stub_kafka_broker_port_https
    preprod     = local.uc_kafka_broker_port_https
    production  = local.uc_kafka_broker_port_https
  }

  ucfs_london_current_domain = local.ucfs_london_domains[local.environment]
  ucfs_london_ha_broker_list = [
    "${local.ucfs_ha_broker_prefix}00.${local.ucfs_london_current_domain}",
    "${local.ucfs_ha_broker_prefix}01.${local.ucfs_london_current_domain}",
    "${local.ucfs_ha_broker_prefix}02.${local.ucfs_london_current_domain}",
    "${local.ucfs_ha_broker_prefix}03.${local.ucfs_london_current_domain}",
    "${local.ucfs_ha_broker_prefix}04.${local.ucfs_london_current_domain}"
  ]

  ucfs_london_bootstrap_servers = {
    development = ["n/a"]                          // stubbed only
    qa          = ["n/a"]                          // stubbed only
    integration = local.ucfs_london_ha_broker_list //this exists on UC's end, but we do not use it as the env is stubbed as at Oct 2020
    preprod     = local.ucfs_london_ha_broker_list
    production  = local.ucfs_london_ha_broker_list
  }

  // This should be a list of server names. For a HA cluster, it will have multiple entries.
  // Intermediate map to allow us to cherry pick Subbed or HA per env
  kafka_london_bootstrap_servers = {
    development = local.stub_bootstrap_servers[local.environment] // stubbed
    qa          = local.stub_bootstrap_servers[local.environment] // stubbed
    integration = local.k2hb_data_source_is_ucfs[local.environment] ? local.ucfs_london_bootstrap_servers[local.environment] : local.stub_bootstrap_servers[local.environment]
    preprod     = local.ucfs_london_bootstrap_servers[local.environment] // now on UCFS Staging HA
    production  = local.ucfs_london_bootstrap_servers[local.environment] // now on UCFS Production HA
  }

  k2hb_alarm_on_consumer_lag_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_consumer_lag_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_consumer_lag_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_consumer_lag_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_failed_batches_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_number_of_batches_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_number_of_batches_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }


  k2hb_alarm_on_number_of_batches_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_number_of_batches_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_running_tasks_less_than_desired_main = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_running_tasks_less_than_desired_main_dedicated = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_running_tasks_less_than_desired_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_running_tasks_less_than_desired_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_running_tasks_less_than_desired_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_failed_batches_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_failed_batches_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_failed_batches_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_dlq_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_dlq_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_dlq_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_dlq_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_kafka_read_timeouts_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_kafka_read_timeouts_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_kafka_read_timeouts_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_kafka_read_timeouts_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_write_timeouts_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_write_timeouts_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_write_timeouts_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_connection_timeouts_ucfs = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_connection_timeouts_audit = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_connection_timeouts_s3only = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  k2hb_alarm_on_hbase_connection_timeouts_equalities = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  deploy_stub_broker = {
    development = true
    qa          = true
    integration = true
    preprod     = false
    production  = false
  }

  k2hb_main_ebs_size = {
    development = 150
    qa          = 150
    integration = 150
    preprod     = 150
    production  = 150
  }

  k2hb_main_ebs_type = {
    development = "gp3"
    qa          = "gp3"
    integration = "gp3"
    preprod     = "gp3"
    production  = "gp3"
  }

  k2hb_main_dedicated_ebs_size = {
    development = 150
    qa          = 150
    integration = 150
    preprod     = 150
    production  = 150
  }

  k2hb_main_dedicated_ebs_type = {
    development = "gp3"
    qa          = "gp3"
    integration = "gp3"
    preprod     = "gp3"
    production  = "gp3"
  }

  k2hb_s3only_dedicated_ebs_size = {
    development = 150
    qa          = 150
    integration = 150
    preprod     = 150
    production  = 150
  }

  k2hb_s3only_dedicated_ebs_type = {
    development = "gp3"
    qa          = "gp3"
    integration = "gp3"
    preprod     = "gp3"
    production  = "gp3"
  }

  k2hb_audit_ebs_size = {
    development = 150
    qa          = 150
    integration = 150
    preprod     = 150
    production  = 150
  }

  k2hb_audit_ebs_type = {
    development = "gp3"
    qa          = "gp3"
    integration = "gp3"
    preprod     = "gp3"
    production  = "gp3"
  }

  k2hb_equalities_ebs_size = {
    development = 150
    qa          = 150
    integration = 150
    preprod     = 150
    production  = 150
  }

  k2hb_equalities_ebs_type = {
    development = "gp3"
    qa          = "gp3"
    integration = "gp3"
    preprod     = "gp3"
    production  = "gp3"
  }

  k2hb_asg_enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupInServiceInstances",
  ]

  batch_coalescer_compute_environment_max_cpus = {
    development = 100
    qa          = 100
    integration = 100
    preprod     = 650
    production  = 650
  }

  batch_coalescer_retry_count = 3

  batch_coalescer_scheduled_executions = {
    development = false
    qa          = false
    integration = false
    preprod     = true
    production  = true
  }

  k2hb_reconciliation_names = {
    ucfs_reconciliation     = "ucfs-reconciliation"
    equality_reconciliation = "equality-reconciliation"
    audit_reconciliation    = "audit-reconciliation"
  }

  k2hb_reconciliation_task_configs = {
    ucfs_reconciliation = {
      table                         = local.ingest_metadata_store_table_names.ucfs
      table_pattern                 = replace(local.k2hb_main_data_qualified_table_pattern, "\\", "\\\\")
      reconciler_fixed_delay_millis = 1
      task_count = {
        development = "1"
        qa          = "1"
        integration = "0" # Not needed in this environment
        preprod     = "0" # Not needed in this environment
        production  = "0" # Will run ad-hoc as and when needed
      }

      table_partitions = {
        development = "8"
        qa          = "8"
        integration = "4"
        preprod     = "4"
        production  = "256"
      }

      partition_lists = {
        development = {
          "p0-p1" = { first = "0", last = "1" },
          "p2-p3" = { first = "2", last = "3" },
          "p4-p5" = { first = "4", last = "5" },
          "p6-p7" = { first = "6", last = "7" }
        }

        qa = {
          "p0-p1" = { first = "0", last = "1" },
          "p2-p3" = { first = "2", last = "3" },
          "p4-p5" = { first = "4", last = "5" },
          "p6-p7" = { first = "6", last = "7" }
        }

        integration = { "p0-p1" = { first = "0", last = "1" }, "p2-p3" = { first = "2", last = "3" } }
        preprod     = { "p0-p1" = { first = "0", last = "1" }, "p2-p3" = { first = "2", last = "3" } }
        production = { "p0-p7" = { "first" = "0", "last" = "7" },
          "p8-p15"    = { "first" = "8", "last" = "15" },
          "p16-p23"   = { "first" = "16", "last" = "23" },
          "p24-p31"   = { "first" = "24", "last" = "31" },
          "p32-p39"   = { "first" = "32", "last" = "39" },
          "p40-p47"   = { "first" = "40", "last" = "47" },
          "p48-p55"   = { "first" = "48", "last" = "55" },
          "p56-p63"   = { "first" = "56", "last" = "63" },
          "p64-p71"   = { "first" = "64", "last" = "71" },
          "p72-p79"   = { "first" = "72", "last" = "79" },
          "p80-p87"   = { "first" = "80", "last" = "87" },
          "p88-p95"   = { "first" = "88", "last" = "95" },
          "p96-p103"  = { "first" = "96", "last" = "103" },
          "p104-p111" = { "first" = "104", "last" = "111" },
          "p112-p119" = { "first" = "112", "last" = "119" },
          "p120-p127" = { "first" = "120", "last" = "127" },
          "p128-p135" = { "first" = "128", "last" = "135" },
          "p136-p143" = { "first" = "136", "last" = "143" },
          "p144-p151" = { "first" = "144", "last" = "151" },
          "p152-p159" = { "first" = "152", "last" = "159" },
          "p160-p167" = { "first" = "160", "last" = "167" },
          "p168-p175" = { "first" = "168", "last" = "175" },
          "p176-p183" = { "first" = "176", "last" = "183" },
          "p184-p191" = { "first" = "184", "last" = "191" },
          "p192-p199" = { "first" = "192", "last" = "199" },
          "p200-p207" = { "first" = "200", "last" = "207" },
          "p208-p215" = { "first" = "208", "last" = "215" },
          "p216-p223" = { "first" = "216", "last" = "223" },
          "p224-p231" = { "first" = "224", "last" = "231" },
          "p232-p239" = { "first" = "232", "last" = "239" },
          "p240-p247" = { "first" = "240", "last" = "247" },
          "p248-p255" = { "first" = "248", "last" = "255" }
        }
      }

      minimum_age_scale = {
        development = "10"
        qa          = "10"
        integration = "10"
        preprod     = "1"
        production  = "1"
      }

      minimum_age_unit = {
        development = "SECOND"
        qa          = "SECOND"
        integration = "SECOND"
        preprod     = "MINUTE"
        production  = "MINUTE"
      }

      last_checked_scale = {
        development = "2"
        qa          = "2"
        integration = "2"
        preprod     = "30"
        production  = "30"
      }

      last_checked_unit = {
        development = "SECOND"
        qa          = "SECOND"
        integration = "SECOND"
        preprod     = "MINUTE"
        production  = "MINUTE"
      }

      log_level = {
        development = "INFO"
        qa          = "INFO"
        integration = "INFO"
        preprod     = "INFO"
        production  = "INFO"
      }
      hbase_client_operation_timeout_ms = {
        development = "900000"
        qa          = "900000"
        integration = "900000"
        preprod     = "900000"
        production  = "900000"
      }
      hbase_client_meta_operation_timeout_ms = {
        development = "900000"
        qa          = "900000"
        integration = "900000"
        preprod     = "900000"
        production  = "900000"
      }
      hbase_client_scanner_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_rpc_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_rpc_read_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_retries = {
        development = "50"
        qa          = "50"
        integration = "50"
        preprod     = "50"
        production  = "50"
      }
      hbase_client_pause_ms = {
        development = "100"
        qa          = "100"
        integration = "100"
        preprod     = "100"
        production  = "100"
      }
      hbase_replication_factor = {
        development = "3"
        qa          = "3"
        integration = "3"
        preprod     = "3"
        production  = "3"
      }
      number_of_parallel_updates = {
        development = "30"
        qa          = "30"
        integration = "30"
        preprod     = "30"
        production  = "30"
      }
      batch_size = {
        development = "100000"
        qa          = "100000"
        integration = "100000"
        preprod     = "100000"
        production  = "100000"
      }
      auto_commit_statements = {
        development = false
        qa          = false
        integration = false
        preprod     = false
        production  = false
      }
    }

    equality_reconciliation = {
      table                         = local.ingest_metadata_store_table_names.equality
      table_pattern                 = replace(local.k2hb_data_equality_qualified_table_pattern, "\\", "\\\\")
      reconciler_fixed_delay_millis = 10000
      task_count = {
        development = "1"
        qa          = "1"
        integration = "1"
        preprod     = "0" # Not needed in this environment
        production  = "1"
      }

      table_partitions = {
        development = "4"
        qa          = "4"
        integration = "4"
        preprod     = "4"
        production  = "4"
      }

      partition_lists = {
        development = { "p0-p3" = { first = "0", last = "3" } }
        qa          = { "p0-p3" = { first = "0", last = "3" } }
        integration = { "p0-p3" = { first = "0", last = "3" } }
        preprod     = { "p0-p3" = { first = "0", last = "3" } }
        production  = { "p0-p3" = { first = "0", last = "3" } }
      }

      minimum_age_scale = {
        development = "10"
        qa          = "10"
        integration = "10"
        preprod     = "1"
        production  = "1"
      }
      minimum_age_unit = {
        development = "SECOND"
        qa          = "SECOND"
        integration = "SECOND"
        preprod     = "MINUTE"
        production  = "MINUTE"
      }
      last_checked_scale = {
        development = "2"
        qa          = "2"
        integration = "2"
        preprod     = "30"
        production  = "30"
      }

      last_checked_unit = {
        development = "SECOND"
        qa          = "SECOND"
        integration = "SECOND"
        preprod     = "MINUTE"
        production  = "MINUTE"
      }
      log_level = {
        development = "INFO"
        qa          = "INFO"
        integration = "INFO"
        preprod     = "INFO"
        production  = "INFO"
      }
      hbase_client_operation_timeout_ms = {
        development = "900000"
        qa          = "900000"
        integration = "900000"
        preprod     = "900000"
        production  = "900000"
      }
      hbase_client_meta_operation_timeout_ms = {
        development = "900000"
        qa          = "900000"
        integration = "900000"
        preprod     = "900000"
        production  = "900000"
      }
      hbase_client_scanner_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_rpc_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_rpc_read_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_retries = {
        development = "50"
        qa          = "50"
        integration = "50"
        preprod     = "50"
        production  = "50"
      }
      hbase_client_pause_ms = {
        development = "100"
        qa          = "100"
        integration = "100"
        preprod     = "100"
        production  = "100"
      }
      hbase_replication_factor = {
        development = "3"
        qa          = "3"
        integration = "3"
        preprod     = "3"
        production  = "3"
      }
      number_of_parallel_updates = {
        development = "10"
        qa          = "10"
        integration = "10"
        preprod     = "10"
        production  = "10"
      }
      batch_size = {
        development = "10000"
        qa          = "10000"
        integration = "10000"
        preprod     = "10000"
        production  = "10000"
      }
      auto_commit_statements = {
        development = false
        qa          = false
        integration = false
        preprod     = false
        production  = false
      }
    }

    audit_reconciliation = {
      table                         = local.ingest_metadata_store_table_names.audit
      table_pattern                 = replace(local.k2hb_data_audit_qualified_table_pattern, "\\", "\\\\")
      reconciler_fixed_delay_millis = 10000
      task_count = {
        development = "1"
        qa          = "1"
        integration = "1"
        preprod     = "0" # Not needed in this environment
        production  = "0" # Will run ad-hoc as and when needed
      }

      table_partitions = {
        development = "4"
        qa          = "4"
        integration = "4"
        preprod     = "4"
        production  = "256"
      }

      partition_lists = {
        development = { "p0-p1" = { first = "0", last = "1" }, "p2-p3" = { first = "2", last = "3" } }
        qa          = { "p0-p1" = { first = "0", last = "1" }, "p2-p3" = { first = "2", last = "3" } }
        integration = { "p0-p1" = { first = "0", last = "1" }, "p2-p3" = { first = "2", last = "3" } }
        preprod     = { "p0-p1" = { first = "0", last = "1" }, "p2-p3" = { first = "2", last = "3" } }
        production = {
          "p0-p7"     = { "first" = "0", "last" = "7" },
          "p8-p15"    = { "first" = "8", "last" = "15" },
          "p16-p23"   = { "first" = "16", "last" = "23" },
          "p24-p31"   = { "first" = "24", "last" = "31" },
          "p32-p39"   = { "first" = "32", "last" = "39" },
          "p40-p47"   = { "first" = "40", "last" = "47" },
          "p48-p55"   = { "first" = "48", "last" = "55" },
          "p56-p63"   = { "first" = "56", "last" = "63" },
          "p64-p71"   = { "first" = "64", "last" = "71" },
          "p72-p79"   = { "first" = "72", "last" = "79" },
          "p80-p87"   = { "first" = "80", "last" = "87" },
          "p88-p95"   = { "first" = "88", "last" = "95" },
          "p96-p103"  = { "first" = "96", "last" = "103" },
          "p104-p111" = { "first" = "104", "last" = "111" },
          "p112-p119" = { "first" = "112", "last" = "119" },
          "p120-p127" = { "first" = "120", "last" = "127" },
          "p128-p135" = { "first" = "128", "last" = "135" },
          "p136-p143" = { "first" = "136", "last" = "143" },
          "p144-p151" = { "first" = "144", "last" = "151" },
          "p152-p159" = { "first" = "152", "last" = "159" },
          "p160-p167" = { "first" = "160", "last" = "167" },
          "p168-p175" = { "first" = "168", "last" = "175" },
          "p176-p183" = { "first" = "176", "last" = "183" },
          "p184-p191" = { "first" = "184", "last" = "191" },
          "p192-p199" = { "first" = "192", "last" = "199" },
          "p200-p207" = { "first" = "200", "last" = "207" },
          "p208-p215" = { "first" = "208", "last" = "215" },
          "p216-p223" = { "first" = "216", "last" = "223" },
          "p224-p231" = { "first" = "224", "last" = "231" },
          "p232-p239" = { "first" = "232", "last" = "239" },
          "p240-p247" = { "first" = "240", "last" = "247" },
          "p248-p255" = { "first" = "248", "last" = "255" }
        }
      }

      minimum_age_scale = {
        development = "10"
        qa          = "10"
        integration = "10"
        preprod     = "1"
        production  = "1"
      }
      minimum_age_unit = {
        development = "SECOND"
        qa          = "SECOND"
        integration = "SECOND"
        preprod     = "MINUTE"
        production  = "MINUTE"
      }
      last_checked_scale = {
        development = "2"
        qa          = "2"
        integration = "2"
        preprod     = "30"
        production  = "30"
      }

      last_checked_unit = {
        development = "SECOND"
        qa          = "SECOND"
        integration = "SECOND"
        preprod     = "MINUTE"
        production  = "MINUTE"
      }
      log_level = {
        development = "INFO"
        qa          = "INFO"
        integration = "INFO"
        preprod     = "INFO"
        production  = "INFO"
      }
      hbase_client_operation_timeout_ms = {
        development = "900000"
        qa          = "900000"
        integration = "900000"
        preprod     = "900000"
        production  = "900000"
      }
      hbase_client_meta_operation_timeout_ms = {
        development = "900000"
        qa          = "900000"
        integration = "900000"
        preprod     = "900000"
        production  = "900000"
      }
      hbase_client_scanner_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_rpc_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_rpc_read_timeout_ms = {
        development = "600000"
        qa          = "600000"
        integration = "600000"
        preprod     = "600000"
        production  = "600000"
      }
      hbase_client_retries = {
        development = "50"
        qa          = "50"
        integration = "50"
        preprod     = "50"
        production  = "50"
      }
      hbase_client_pause_ms = {
        development = "100"
        qa          = "100"
        integration = "100"
        preprod     = "100"
        production  = "100"
      }
      hbase_replication_factor = {
        development = "3"
        qa          = "3"
        integration = "3"
        preprod     = "3"
        production  = "3"
      }
      number_of_parallel_updates = {
        development = "10"
        qa          = "10"
        integration = "10"
        preprod     = "10"
        production  = "10"
      }
      batch_size = {
        development = "10000"
        qa          = "10000"
        integration = "10000"
        preprod     = "10000"
        production  = "10000"
      }
      auto_commit_statements = {
        development = false
        qa          = false
        integration = false
        preprod     = false
        production  = false
      }
    }
  }

  k2hb_trim_reconciled_records_names = {
    ucfs_trim_reconciled_records     = "ucfs-trim-reconciled-records"
    equality_trim_reconciled_records = "equality-trim-reconciled-records"
    audit_trim_reconciled_records    = "audit-trim-reconciled-records"
  }

  k2hb_trimmer_common_config = {
    log_level = {
      development = "INFO"
      qa          = "INFO"
      integration = "INFO"
      preprod     = "INFO"
      production  = "INFO"
    }
    number_of_parallel_updates = 0 // not used by trimmer but required
    batch_size                 = 0 // not used by trimmer but required
    optimize_after_delete = {
      development = true
      qa          = true
      integration = true
      preprod     = true
      production  = true
    }
    spring_profiles_active = {
      development = "TRIM_RECONCILED_RECORDS"
      qa          = "TRIM_RECONCILED_RECORDS"
      integration = "TRIM_RECONCILED_RECORDS"
      preprod     = "TRIM_RECONCILED_RECORDS"
      production  = "TRIM_RECONCILED_RECORDS"
    }
    audit_trim_reconciled_records = {
      table = local.ingest_metadata_store_table_names.audit
      reconciler_trim_reconciled_fixed_delay_millis = {
        development = "10000"
        qa          = "10000"
        integration = "10000"
        preprod     = "3600000" // Run hourly to reduce contention as this is a locking delete call
        production  = "3600000" // Run hourly to reduce contention as this is a locking delete call
      }
      task_count = {
        development = "1"
        qa          = "1"
        integration = "1"
        preprod     = "1"
        production  = "1"
      }
      trim_reconciled_scale = {
        development = "1"
        qa          = "1"
        integration = "1"
        preprod     = "1"
        production  = "1"
      }
      trim_reconciled_unit = {
        development = "DAY"
        qa          = "DAY"
        integration = "DAY"
        preprod     = "DAY"
        production  = "DAY"
      }
      log_level = {
        development = "INFO"
        qa          = "INFO"
        integration = "INFO"
        preprod     = "INFO"
        production  = "INFO"
      }
      number_of_parallel_updates = 0 // not used by trimmer but required
      batch_size                 = 0 // not used by trimmer but required
      optimize_after_delete = {
        development = true
        qa          = true
        integration = true
        preprod     = true
        production  = true
      }
      spring_profiles_active = {
        development = "TRIM_RECONCILED_RECORDS"
        qa          = "TRIM_RECONCILED_RECORDS"
        integration = "TRIM_RECONCILED_RECORDS"
        preprod     = "TRIM_RECONCILED_RECORDS"
        production  = "TRIM_RECONCILED_RECORDS"
      }
    }
  }

  cw_k2hb_reconciliation_trimmer_namespace = {
    ucfs_reconciliation     = "/aws/ecs/main/ucfs-reconciliation-trimmer"
    equality_reconciliation = "/aws/ecs/main/equality-reconciliation-trimmer"
    audit_reconciliation    = "/aws/ecs/main/audit-reconciliation-trimmer"
  }

  cw_k2hb_reconciliation_ucfs_namespace     = "/aws/ecs/main/ucfs-reconciliation"
  cw_k2hb_reconciliation_equality_namespace = "/aws/ecs/main/equality-reconciliation"
  cw_k2hb_reconciliation_audit_namespace    = "/aws/ecs/main/audit-reconciliation"

  k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records = {
    ucfs_reconciliation     = "The number of UCFS records successfully reconciled"
    equality_reconciliation = "The number of Equality records successfully reconciled"
    audit_reconciliation    = "The number of Audit records successfully reconciled"
  }

  k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation = {
    ucfs_reconciliation     = "The number of UCFS records which failed to be reconciled"
    equality_reconciliation = "The number of Equality records which failed to be reconciled"
    audit_reconciliation    = "The number of Audit records which failed to be reconciled"
  }

  k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed = {
    ucfs_reconciliation     = "The number of UCFS records which have been trimmed"
    equality_reconciliation = "The number of Equality records which have been trimmed"
    audit_reconciliation    = "The number of Audit records which have been trimmed"
  }

  k2hb_reconciliation_trimmer_log_group_name = "/aws/batch/job"

  ucfs_historic_data_prefix = "${data.terraform_remote_state.ingest.outputs.ingest_emr_s3_prefixes.base_root_prefix}/mongo"

  manifest_comparison_import_csv_table_name                    = "import_csv"
  manifest_comparison_export_csv_table_name                    = "export_csv"
  manifest_comparison_combined_parquet_table_name              = "manifest_combined_parquet"
  manifest_comparison_missing_imports_parquet_table_name       = "manifest_missing_imports_parquet"
  manifest_comparison_missing_exports_parquet_table_name       = "manifest_missing_exports_parquet"
  manifest_comparison_counts_parquet_table_name                = "manifest_counts_parquet"
  manifest_comparison_mismatched_timestamps_parquet_table_name = "manifest_mismatched_timestamps_parquet"
}
