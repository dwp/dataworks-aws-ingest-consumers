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

  k2hb_main_ha_cluster_consumer_name = "k2hb-main-ha-cluster"
  k2hb_equality_consumer_name        = "k2hb-equality"

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

  k2hb_write_manifests_main = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  k2hb_write_manifests_equality = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  k2hb_auto_commit_metadata_store_inserts_main = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  k2hb_auto_commit_metadata_store_inserts_equality = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  k2s3_log_level = {
    development = "DEBUG"
    qa          = "INFO"
    integration = "INFO"
    preprod     = "INFO"
    production  = "INFO"
  }


  k2hb_kafka_main_consumer_group     = "dataworks-ucfs-kafka-to-hbase-ingest-${local.environment}"
  k2hb_kafka_equality_consumer_group = "dataworks-ucfs-kafka-equality-to-hbase-ingest-${local.environment}"

  kafka_consumer_truststore_aliases = {
    development = "ucfs_ca"
    qa          = "ucfs_ca"
    integration = "ucfs_ca"
    preprod     = "ucfs_ca"
    production  = "ucfs_ca,ucfs_ca_old"
  }

  kafka_consumer_truststore_certs = {
    development = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    qa          = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    integration = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    preprod     = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem"
    production  = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/ucfs/root_ca.pem,s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/ucfs/root_ca_old.pem"
  }

  cw_k2hb_agent_namespace                               = "/app/kafka-to-hbase"
  cw_k2hb_equality_agent_namespace                      = "/app/kafka-to-hbase-equality"
  cw_agent_metrics_collection_interval                  = 60
  cw_agent_cpu_metrics_collection_interval              = 60
  cw_agent_disk_measurement_metrics_collection_interval = 60
  cw_agent_disk_io_metrics_collection_interval          = 60
  cw_agent_mem_metrics_collection_interval              = 60
  cw_agent_netstat_metrics_collection_interval          = 60

  k2hb_data_family = {
    development = "cf"
    qa          = "cf"
    integration = "cf"
    preprod     = "cf"
    production  = "cf"
  }

  k2hb_data_qualifier = {
    development = "record"
    qa          = "record"
    integration = "record"
    preprod     = "record"
    production  = "record"
  }

  # These should be in ISO-8601 duration format, see https://en.wikipedia.org/wiki/ISO_8601
  # The poll timeout is the longest time we will wait for talking to the downstream system (i.e. hbase) before
  # we give up
  kafka_k2hb_poll_timeout = {
    development = "PT5M"
    qa          = "PT5M"
    integration = "PT5M"
    preprod     = "PT5M"
    production  = "PT10M"
  }

  # This is how often we promise to talk to the kafka broker so we do not get kicked out of the consumer group
  # This should be greater than the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_max_poll_interval_ms = {
    development = 600000
    qa          = 600000
    integration = 600000
    preprod     = 600000
    production  = 1800000
  }

  # This should be the number of records we can easily process within the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_max_poll_records_count_main = {
    development = 25
    qa          = 50
    integration = 50
    preprod     = 25
    production  = 5000
  }

  # This should be the number of records we can easily process within the client timeout (kafka_k2hb_poll_timeout) above
  k2hb_max_poll_records_count_equality = {
    development = 25
    qa          = 50
    integration = 50
    preprod     = 25
    production  = 1000
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
    preprod     = "60000"
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

  kafka_consumer_main_topics_regex = {
    //match any "db.*" collections i.e. db.aa.bb, with only two literal dots allowed
    //DW-4748 & DW-4827 - Allow extra dot in last matcher group for db.crypto.encryptedData.unencrypted
    development = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    qa          = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    integration = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    preprod     = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    production  = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
  }

  // Use in DW-4508
  kafka_consumer_equality_topics_regex = {
    //match exactly "data.equality" only, with a literal dot
    development = "^(data[.]equality)$"
    qa          = "^(data[.]equality)$"
    integration = "^(data[.]equality)$"
    preprod     = "^(data[.]equality)$"
    production  = "^(data[.]equality)$"
  }

  // For future use when we do audit data
  kafka_consumer_audit_topics_regex = {
    // match exactly "data.businessAudit" only, with a literal dot
    development = "^(data[.]businessAudit)$"
    qa          = "^(data[.]businessAudit)$"
    integration = "^(data[.]businessAudit)$"
    preprod     = "^(data[.]businessAudit)$"
    production  = "^(data[.]businessAudit)$"
  }

  kafka_k2hb_meta_refresh_ms = {
    development = "10000"
    qa          = "10000"
    integration = "10000"
    preprod     = "10000"
    production  = "100000"
  }

  // DW-4748 & DW-4827 - Allow extra dot in last matcher group for db.crypto.encryptedData.unencrypted
  k2hb_main_data_qualified_table_pattern = "^\\w+\\.([-\\w]+)\\.([-.\\w]+)$"

  // Only needs to work for exactly "data.equality"
  k2hb_data_equality_qualified_table_pattern = "^([-\\w]+)\\.([-\\w]+)$"
  // This will be used when we consume audit data
  k2hb_data_audit_qualified_table_pattern = "^([-\\w]+)\\.([-\\w]+)$"

  dlq_kafka_consumer_topics = {
    development = "dataworks.ucfs-business-data-event-dlq"
    qa          = "dataworks.ucfs-business-data-event-dlq"
    integration = "dataworks.ucfs-business-data-event-dlq"
    preprod     = "dataworks.ucfs-business-data-event-dlq"
    production  = "dataworks.ucfs-business-data-event-dlq"
  }

  k2hb_validator_schema = {
    ucfs     = "business_message.schema.json" //this is the default if not specified, version 0.0.153++
    equality = "equality_message.schema.json"
    audit    = "audit_message.schema.json" // for future use
  }

  k2hb_equality_write_to_metadata_store = {
    development = true
    qa          = true
    integration = true
    preprod     = true
    production  = true
  }

  k2hb_main_ha_cluster_write_to_metadata_store = {
    development = true
    qa          = true
    integration = true
    preprod     = true
    production  = true
  }


}
