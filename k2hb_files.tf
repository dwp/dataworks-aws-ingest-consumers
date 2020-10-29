data "local_file" "amazon_root_ca1_pem" {
  filename = "files/k2hb/AmazonRootCA1.pem"
}

resource "aws_s3_bucket_object" "amazon_root_ca1_pem" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/AmazonRootCA1.pem"
  content    = data.local_file.amazon_root_ca1_pem.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "amazon-root-ca1-pem"
    },
  )
}

data "local_file" "k2hb_init_script" {
  filename = "files/k2hb/k2hb"
}

resource "aws_s3_bucket_object" "k2hb_init_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/k2hb"
  content    = data.local_file.k2hb_init_script.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-init-script"
    },
  )
}

data "local_file" "k2hb_logrotate_script" {
  filename = "files/k2hb/k2hb.logrotate"
}

resource "aws_s3_bucket_object" "k2hb_logrotate_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/k2hb.logrotate"
  content    = data.local_file.k2hb_logrotate_script.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-logrotate-script"
    },
  )
}

data "local_file" "k2hb_shell_script" {
  filename = "files/k2hb/k2hb.sh"
}

resource "aws_s3_bucket_object" "k2hb_shell_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/k2hb.sh"
  content    = data.local_file.k2hb_shell_script.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-shell-script"
    },
  )
}

data "local_file" "k2hb_cloudwatch_script" {
  filename = "files/k2hb/k2hb_cloudwatch.sh"
}

resource "aws_s3_bucket_object" "k2hb_cloudwatch_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/k2hb_cloudwatch.sh"
  content    = data.local_file.k2hb_cloudwatch_script.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-cloudwatch-script"
    },
  )
}

data "local_file" "respawn_k2hb_script" {
  filename = "files/k2hb/respawn_k2hb.sh"
}

resource "aws_s3_bucket_object" "respawn_k2hb_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/respawn_k2hb.sh"
  content    = data.local_file.respawn_k2hb_script.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-respawn-k2hb-script"
    },
  )
}

data "local_file" "logging_script" {
  filename = "files/k2hb/logging.sh"
}

resource "aws_s3_bucket_object" "logging_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/k2hb/logging.sh"
  content    = data.local_file.logging_script.content
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-logging-script"
    },
  )
}
