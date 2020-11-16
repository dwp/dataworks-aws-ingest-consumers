#!/bin/bash

# Force LC update when any of these files are changed
echo "${s3_script_hash_k2hb_sh}" > /dev/null
echo "${s3_script_hash_k2hb_init}" > /dev/null
echo "${s3_script_hash_k2hb_logrotate}" > /dev/null
echo "${s3_script_hash_k2hb_cloudwatch_sh}" > /dev/null
echo "${s3_script_hash_common_logging_sh}" > /dev/null
echo "${s3_script_hash_logging_sh}" > /dev/null
echo "${s3_script_hash_respawn_k2hb_sh}" > /dev/null
echo "${s3_script_hash_amazon_root_ca1_pem}" > /dev/null

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

export http_proxy="http://${internet_proxy}:3128"
export HTTP_PROXY="$http_proxy"
export https_proxy="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export no_proxy="${non_proxied_endpoints}"
export NO_PROXY="$no_proxy"

echo "Configure AWS Inspector"
cat > /etc/init.d/awsagent.env << AWSAGENTPROXYCONFIG
export https_proxy=$https_proxy
export http_proxy=$http_proxy
export no_proxy=$no_proxy
AWSAGENTPROXYCONFIG

/etc/init.d/awsagent stop
sleep 5
/etc/init.d/awsagent start

echo "Configuring startup scripts paths"
S3_URI_SHELL="s3://${s3_scripts_bucket}/${s3_script_key_k2hb_sh}"
S3_URI_INIT="s3://${s3_scripts_bucket}/${s3_script_key_k2hb_init}"
S3_URI_LOGROTATE="s3://${s3_scripts_bucket}/${s3_script_key_k2hb_logrotate}"
S3_CLOUDWATCH_SHELL="s3://${s3_scripts_bucket}/${s3_script_k2hb_cloudwatch_sh}"
S3_COMMON_LOGGING_SHELL="s3://${s3_scripts_bucket}/${s3_script_common_logging_sh}"
S3_LOGGING_SHELL="s3://${s3_scripts_bucket}/${s3_script_logging_sh}"
S3_RESPAWN_K2HB="s3://${s3_scripts_bucket}/${s3_script_respawn_k2hb_sh}"
echo "Configuring startup file paths"
S3_AMAZON_ROOT_CA1_PEM="s3://${s3_scripts_bucket}/${s3_script_amazon_root_ca1_pem}"

echo "Installing startup scripts"
$(which aws) s3 cp "$S3_URI_SHELL"              /opt/k2hb/k2hb.sh
$(which aws) s3 cp "$S3_URI_INIT"               /etc/init.d/k2hb
$(which aws) s3 cp "$S3_URI_LOGROTATE"          /etc/logrotate.d/k2hb
$(which aws) s3 cp "$S3_CLOUDWATCH_SHELL"       /opt/k2hb/k2hb_cloudwatch.sh
$(which aws) s3 cp "$S3_COMMON_LOGGING_SHELL"   /opt/k2hb/common_logging.sh
$(which aws) s3 cp "$S3_LOGGING_SHELL"          /opt/k2hb/logging.sh
$(which aws) s3 cp "$S3_RESPAWN_K2HB"           /opt/k2hb/respawn_k2hb.sh
echo "Installing startup files"
$(which aws) s3 cp "$S3_AMAZON_ROOT_CA1_PEM"    /opt/k2hb/AmazonRootCA1.pem

echo "Allow shutting down"
echo "k2hb     ALL = NOPASSWD: /sbin/shutdown -h now" >> /etc/sudoers

echo "Creating directories"
mkdir -p /var/log/k2hb

echo "Creating user k2hb"
useradd k2hb -m

echo "Setup cloudwatch logs"
chmod u+x /opt/k2hb/k2hb_cloudwatch.sh
/opt/k2hb/k2hb_cloudwatch.sh \
    "${cwa_metrics_collection_interval}" "${cwa_namespace}" "${cwa_cpu_metrics_collection_interval}" \
    "${cwa_disk_measurement_metrics_collection_interval}" "${cwa_disk_io_metrics_collection_interval}" \
    "${cwa_mem_metrics_collection_interval}" "${cwa_netstat_metrics_collection_interval}" "${cwa_log_group_name}" \
    "$AWS_DEFAULT_REGION"

echo "Download & install latest k2hb service artifact"
VERSION="${k2hb_version}"
URL="s3://${s3_artefact_bucket_id}/kafka-to-hbase/kafka2hbase-$VERSION.tar.gz"
$(which aws) s3 cp "$URL" /tmp/k2hb.tar.gz
tar -xzf /tmp/k2hb.tar.gz -C /opt/k2hb --strip-components=1
echo "JAR_VERSION: $VERSION"
echo "JAR_DOWNLOAD_URL: $URL"
echo "$VERSION" > /opt/k2hb/version
echo "${k2hb_log_level}" > /opt/k2hb/log_level
echo "${environment_name}" > /opt/k2hb/environment

# Retrieve certificates
K2HB_TRUSTSTORE_PASSWORD=$(uuidgen -r)
K2HB_KEYSTORE_PASSWORD=$(uuidgen -r)
K2HB_PRIVATE_KEY_PASSWORD=$(uuidgen -r)
ACM_KEY_PASSWORD=$(uuidgen -r)

K2HB_KEYSTORE_PATH="/opt/k2hb/keystore.jks"
K2HB_TRUSTSTORE_PATH="/opt/k2hb/truststore.jks"

acm-cert-retriever \
--acm-cert-arn "${acm_cert_arn}" \
--acm-key-passphrase "$ACM_KEY_PASSWORD" \
--keystore-path "$K2HB_KEYSTORE_PATH" \
--keystore-password "$K2HB_KEYSTORE_PASSWORD" \
--private-key-alias "${private_key_alias}" \
--private-key-password "$K2HB_PRIVATE_KEY_PASSWORD" \
--truststore-path "$K2HB_TRUSTSTORE_PATH" \
--truststore-password "$K2HB_TRUSTSTORE_PASSWORD" \
--truststore-aliases "${truststore_aliases}" \
--truststore-certs "${truststore_certs}" >> /var/log/acm-cert-retriever.log 2>&1

echo "Create settings file"
if [[ "${k2hb_max_memory_allocation}" == "NOT_SET" ]]; then
  MAX_MEMORY_ALLOCATION=""
else
  MAX_MEMORY_ALLOCATION="${k2hb_max_memory_allocation}"
fi

cat << EOF > /opt/k2hb/settings
    export APPLICATION="${k2hb_application_name}"
    export COMPONENT="jar_file"
    export APP_VERSION="$VERSION"
    export ENVIRONMENT="${environment_name}"
    export LOG_LEVEL="${k2hb_log_level}"
    export K2HB_KAFKA_CONSUMER_GROUP="${k2hb_kafka_consumer_group}"
    export K2HB_KAFKA_TOPIC_REGEX="${k2hb_kafka_topic_regex}"
    export K2HB_KAFKA_TOPIC_EXCLUSION_REGEX="${k2hb_kafka_topic_exclusion_regex}"
    export K2HB_KAFKA_META_REFRESH_MS="${k2hb_kafka_meta_refresh_ms}"
    export K2HB_KAFKA_MAX_POLL_INTERVAL_MS="${k2hb_kafka_max_poll_interval_ms}"
    export K2HB_KAFKA_POLL_TIMEOUT="${k2hb_kafka_poll_timeout}"
    export K2HB_KAFKA_INSECURE="${k2hb_kafka_insecure}"
    export K2HB_KAFKA_CERT_MODE="${k2hb_kafka_cert_mode}"
    export K2HB_KAFKA_DLQ_TOPIC="${k2hb_kafka_dlq_topic}"
    export RETRIEVER_ACM_CERT_ARN="${acm_cert_arn}"
    export K2HB_KAFKA_MAX_POLL_RECORDS="${k2hb_kafka_poll_max_records}"
    export INTERNET_PROXY="${internet_proxy}"
    export K2HB_HBASE_REGION_REPLICATION="${k2hb_hbase_region_replication}"
    export K2HB_KAFKA_REPORT_FREQUENCY="${k2hb_kafka_report_frequency}"
    export K2HB_HBASE_LOG_KEYS="${k2hb_hbase_log_keys}"
    export K2HB_HBASE_RPC_TIMEOUT_MILLISECONDS="${k2hb_hbase_rpc_timeout_milliseconds}"
    export K2HB_HBASE_OPERATION_TIMEOUT_MILLISECONDS="${k2hb_hbase_client_operation_timeout_milliseconds}"
    export K2HB_HBASE_PAUSE_MILLISECONDS="${k2hb_hbase_pause_milliseconds}"
    export K2HB_HBASE_RETRIES="${k2hb_hbase_retries}"
    export K2HB_RETRY_MAX_ATTEMPTS="${k2hb_retry_max_attempts}"
    export K2HB_USE_AWS_SECRETS="${k2hb_use_aws_secrets}"
    export K2HB_RDS_CA_CERT_PATH="/opt/k2hb/AmazonRootCA1.pem"
    export K2HB_RDS_USERNAME="${k2hb_rds_username}"
    export K2HB_RDS_PASSWORD_SECRET_NAME="${k2hb_rds_password_secret_name}"
    export K2HB_RDS_DATABASE_NAME="${k2hb_rds_database_name}"
    export K2HB_METADATA_STORE_TABLE="${k2hb_rds_table_name}"
    export K2HB_RDS_ENDPOINT="${k2hb_rds_endpoint}"
    export K2HB_TRUSTSTORE_PATH="$K2HB_TRUSTSTORE_PATH"
    export K2HB_TRUSTSTORE_PASSWORD="$K2HB_TRUSTSTORE_PASSWORD"
    export K2HB_KEYSTORE_PATH="$K2HB_KEYSTORE_PATH"
    export K2HB_KEYSTORE_PASSWORD="$K2HB_KEYSTORE_PASSWORD"
    export K2HB_PRIVATE_KEY_PASSWORD="$K2HB_PRIVATE_KEY_PASSWORD"
    export K2HB_HBASE_ZOOKEEPER_PARENT="${k2hb_hbase_zookeeper_parent}"
    export K2HB_HBASE_ZOOKEEPER_QUORUM="${k2hb_hbase_zookeeper_quorum}"
    export K2HB_HBASE_ZOOKEEPER_PORT="${k2hb_hbase_zookeeper_port}"
    export K2HB_HBASE_DATA_FAMILY="${k2hb_hbase_data_family}"
    export K2HB_HBASE_DATA_QUALIFIER="${k2hb_hbase_data_qualifier}"
    export K2HB_KAFKA_BOOTSTRAP_SERVERS="${k2hb_kafka_bootstrap_servers}"
    export K2HB_QUALIFIED_TABLE_PATTERN="${k2hb_qualified_table_pattern}"
    export K2HB_CHECK_EXISTENCE="${k2hb_check_existence}"
    export K2HB_AWS_S3_ARCHIVE_BUCKET="${k2hb_aws_s3_archive_bucket}"
    export K2HB_AWS_S3_ARCHIVE_DIRECTORY="${k2hb_aws_s3_archive_directory}"
    export K2HB_AWS_S3_BATCH_PUTS="${k2hb_aws_s3_batch_puts}"
    export K2HB_VALIDATOR_SCHEMA="${k2hb_validator_schema}"
    export K2HB_WRITE_TO_METADATA_STORE="${k2hb_write_to_metadata_store}"
    export K2HB_AWS_S3_MANIFEST_BUCKET="${k2hb_manifest_bucket}"
    export K2HB_AWS_S3_MANIFEST_DIRECTORY="${k2hb_manifest_prefix}"
    export K2HB_AWS_S3_WRITE_MANIFESTS="${k2hb_write_manifests}"
    export K2HB_METADATA_STORE_AUTO_COMMIT="${k2hb_auto_commit_metadata_store_inserts}"
    export K2HB_KAFKA_MAX_FETCH_BYTES="${k2hb_kafka_max_fetch_bytes}"
    export K2HB_KAFKA_MAX_PARTITION_FETCH_BYTES="${k2hb_kafka_max_partition_fetch_bytes}"
    # JAVA options
    export JAVA_OPTS="$MAX_MEMORY_ALLOCATION -DLOG_DIRECTORY=/var/log/k2hb -Dlogback.debug=true"
EOF

echo "Changing permissions and moving files"
chmod u+x /opt/k2hb/common_logging.sh
chmod u+x /opt/k2hb/logging.sh
chmod u+x /opt/k2hb/k2hb.sh
chmod u+x /etc/init.d/k2hb
chmod u+x /opt/k2hb/respawn_k2hb.sh
chmod u+x /opt/k2hb/bin/kafka2hbase
chown k2hb:k2hb -R  /opt/k2hb
chown k2hb:k2hb -R  /var/log/k2hb

chkconfig --add k2hb
chkconfig k2hb on
service k2hb start

# Adds respawn_k2hb to crontab and run every minute
crontab -l | { cat; echo "* * * * * /opt/k2hb/respawn_k2hb.sh "${k2hb_application_name}" >> /var/log/k2hb/respawn_k2hb.log 2>&1"; } | crontab -
