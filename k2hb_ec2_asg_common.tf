
# Currently deployed by aws-ingest but must be moved here using Terraform import
#
#resource "aws_acm_certificate" "kafka_to_hbase" {
#  certificate_authority_arn = local.certificate_auth_root_ca_arn
#  domain_name               = "consumer.ucfs.${local.env_prefix[local.environment]}dataworks.dwp.gov.uk"
#
#  options {
#    certificate_transparency_logging_preference = "DISABLED"
#  }
#
#  tags = merge(
#    local.common_tags,
#    {
#      Name = "k2hb-cert"
#    },
#  )
#}

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

  k2hb_audit_tags_asg = merge(
    local.common_tags,
    {
      Name         = "${local.k2hb_audit_consumer_name}-${local.environment}",
      k2hb-version = var.k2hb_version,
      AutoShutdown = local.k2hb_audit_asg_autoshutdown[local.environment],
      SSMEnabled   = local.k2hb_audit_asg_ssmenabled[local.environment],
      Inspector    = local.k2hb_audit_asg_inspector[local.environment],
      Persistence  = "Ignore",
    }
  )
}


resource "aws_iam_instance_profile" "k2hb_common" {
  name = "k2hb_common"
  role = aws_iam_role.k2hb_common.name
}

data "aws_iam_policy_document" "k2hb_common" {
  statement {
    sid    = "AllowACM"
    effect = "Allow"

    actions = [
      "acm:*Certificate",
    ]

    resources = [local.ingest_k2hb_cert_arn]

  }

  statement {
    sid    = "GetPublicCerts"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [local.certificate_auth_public_cert_bucket.arn]
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

    resources = [local.security_tools_ebs_cmk_arn]
  }

  statement {
    effect = "Allow"
    sid    = "AllowAccessToConfigBucket"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [local.common_config_bucket.arn]
  }

  statement {
    effect = "Allow"
    sid    = "AllowAccessToConfigBucketObjects"

    actions = ["s3:GetObject"]

    resources = ["${local.common_config_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowKMSDecryptionOfS3ConfigBucketObj"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [local.common_config_bucket_cmk_arn]
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

    resources = [local.ingest_input_bucket_cmk_arn]
  }

  statement {
    sid     = "AllowAccessToArtefactBucket"
    effect  = "Allow"
    actions = ["s3:GetBucketLocation"]

    resources = [local.managemant_artefact_bucket.arn]
  }

  statement {
    sid       = "AllowPullFromArtefactBucket"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${local.managemant_artefact_bucket.arn}/*"]
  }

  statement {
    sid    = "AllowDecryptArtefactBucket"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [local.managemant_artefact_bucket.cmk_arn]
  }

  statement {
    sid    = "AllowK2HBToAccessLogGroups"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      local.ingest_log_groups.k2hb_ec2_logs.arn,
      local.ingest_log_groups.k2hb_ec2_equality_logs.arn
    ]
  }

  statement {
    sid    = "AllowK2HBToGetSecretManagerPassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      local.ingest_metadata_store.credentials.metadata_store_k2hbwriter.arn,
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
      "${local.internal_compute_manifest_bucket.arn}/${local.internal_compute_manifest_s3_prefixes.base}/*",
    ]
  }

  statement {
    sid    = "ListManifests"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      local.internal_compute_manifest_bucket.arn,
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
      local.internal_compute_manifest_bucket_cmk.arn,
    ]
  }
}

data "aws_iam_policy_document" "k2hb_common_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k2hb_common" {
  name                 = "k2hb_common"
  assume_role_policy   = data.aws_iam_policy_document.k2hb_common_policy.json
  max_session_duration = local.iam_role_max_session_timeout_seconds

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb_common"
    }
  )
}

resource "aws_iam_policy" "k2hb_common" {
  name        = "k2hb_common"
  description = "Policy to allow access for K2HB"
  policy      = data.aws_iam_policy_document.k2hb_common.json
}

resource "aws_iam_role_policy_attachment" "k2hb_common" {
  role       = aws_iam_role.k2hb_common.name
  policy_arn = aws_iam_policy.k2hb_common.arn
}

resource "aws_iam_role_policy_attachment" "k2hb_common_cwasp" {
  role       = aws_iam_role.k2hb_common.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "k2hb_common_ssm" {
  role       = aws_iam_role.k2hb_common.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# This updates the broker security group to let us in
resource "aws_security_group_rule" "k2hb_common_ec2_to_stub_ucfs_kafka" {
  count                    = local.stub_ucfs_deploy_broker[local.environment] ? length(local.stub_ucfs_kafka_ports) : 0
  description              = "K2HB Common ec2 to stub broker"
  type                     = "ingress"
  source_security_group_id = aws_security_group.k2hb_common.id
  protocol                 = "tcp"
  from_port                = local.stub_ucfs_kafka_ports[count.index]
  to_port                  = local.stub_ucfs_kafka_ports[count.index]
  security_group_id        = local.stub_ucfs_sg_id
}

resource "aws_security_group" "k2hb_common" {
  name                   = "k2hb_common"
  description            = "Contains rules for k2hb consumers"
  revoke_rules_on_delete = true
  vpc_id                 = local.ingest_vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb-common"
    },
  )
}

resource "aws_security_group_rule" "k2hb_common_to_s3" {
  description       = "Allow kafka-to-hbase to reach S3 (for the jar)"
  type              = "egress"
  prefix_list_ids   = [local.ingest_vpc_prefix_list_ids_s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_s3_http" {
  description       = "Allow kafka-to-hbase to reach S3 (for Yum) http"
  type              = "egress"
  prefix_list_ids   = [local.ingest_vpc_prefix_list_ids_s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "egress_k2hb_common_to_internet" {
  description              = "Allow k2hb access to Internet Proxy (for ACM-PCA)"
  type                     = "egress"
  source_security_group_id = local.ingest_internet_proxy.sg
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "ingress_k2hb_common_to_internet" {
  description              = "Allow k2hb access to Internet Proxy (for ACM-PCA)"
  type                     = "ingress"
  source_security_group_id = aws_security_group.k2hb_common.id
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = local.ingest_internet_proxy.sg
}

resource "aws_security_group_rule" "k2hb_common_to_stub_broker" {
  count             = local.k2hb_data_source_is_ucfs[local.environment] ? 0 : 1
  description       = "Allow k2hb to reach stub Kafka brokers"
  type              = "egress"
  from_port         = local.kafka_broker_port[local.environment]
  to_port           = local.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = local.stub_ucfs_subnets.cidr_block
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_ucfs_broker" {
  count             = local.k2hb_data_source_is_ucfs[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach UCFS Kafka brokers (Ireland)"
  type              = "egress"
  from_port         = local.kafka_broker_port[local.environment]
  to_port           = local.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_broker_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_ucfs_london_broker" {
  count             = local.k2hb_data_source_is_ucfs[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach UCFS Kafka brokers (London)"
  type              = "egress"
  from_port         = local.kafka_broker_port[local.environment]
  to_port           = local.kafka_broker_port[local.environment]
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_london_broker_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_ucfs_ireland_dns_tcp" {
  count             = local.peer_with_ucfs[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach ucfs DNS name servers"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_ucfs_ireland_dns_udp" {
  count             = local.peer_with_ucfs[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach ucfs DNS name servers"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = local.ucfs_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_ucfs_london_dns_tcp" {
  count             = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach UCFS DNS (London)"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = local.ucfs_london_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_to_ucfs_london_dns_udp" {
  count             = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  description       = "Allow k2hb to reach UCFS DNS (London)"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = local.ucfs_london_nameservers_cidr_blocks[local.environment]
  security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_egress_hbase" {
  for_each                 = { for hbase_emr_port in local.hbase_emr_ports : hbase_emr_port.port => hbase_emr_port }
  description              = "Allow outbound requests to ${each.value.name}"
  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  source_security_group_id = local.ingest_hbase_emr_common_sg_id
  security_group_id        = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_ingress_hbase" {
  for_each                 = { for hbase_emr_port in local.hbase_emr_ports : hbase_emr_port.port => hbase_emr_port }
  description              = "Allow inbound requests from ${each.value.name}"
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = local.ingest_hbase_emr_common_sg_id
  source_security_group_id = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "k2hb_common_egress_metadata_store" {
  description              = "Allow outbound requests to Metadata Store DB"
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = local.ingest_metadata_store.rds.sg_id
  security_group_id        = aws_security_group.k2hb_common.id
}

resource "aws_security_group_rule" "metadata_store_from_k2hb_common" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_common.id
  security_group_id        = local.ingest_metadata_store.rds.sg_id
  description              = "Metadata store from K2HB ec2"
}

resource "aws_security_group_rule" "k2hb_common_to_vpc_endpoints" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = local.ingest_vpc_interface_vpce_sg_id
  security_group_id        = aws_security_group.k2hb_common.id
  description              = "K2HB ec2 to VPC endpoints"
}

resource "aws_security_group_rule" "vpc_endpoints_from_k2hb_common" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_common.id
  security_group_id        = local.ingest_vpc_interface_vpce_sg_id
  description              = "VPC endpoints from K2HB ec2"
}
