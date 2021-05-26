locals {
  k2hb_reconciliation_container_url = "${local.account.management}.${module.vpc.ecr_dkr_domain_name}/kafka-to-hbase-reconciliation${var.k2hb_reconciliation_container_version}"
}

# IAM
data "aws_iam_policy_document" "k2hb_reconciliation" {

  statement {
    sid    = "GetPassword"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.metadata_store_reconciler.arn,
    ]
  }

  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [for v in aws_cloudwatch_log_group.k2hb_reconciliation_k2hb : v.arn]
  }
}

resource "aws_iam_role" "k2hb_reconciliation" {
  name               = "k2hb_reconciliation"
  assume_role_policy = data.terraform_remote_state.common.outputs.ecs_assume_role_policy_json

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb_reconciliation"
    }
  )
}

resource "aws_iam_role_policy" "k2hb_reconciliation" {
  policy = data.aws_iam_policy_document.k2hb_reconciliation.json
  role   = aws_iam_role.k2hb_reconciliation.id
}

# Cloudwatch
resource "aws_cloudwatch_log_group" "k2hb_reconciliation_k2hb" {
  for_each = local.k2hb_reconciliation_names

  name              = "/aws/ecs/main/${each.value}_k2hb"
  retention_in_days = 180

  tags = merge(
    local.common_tags,
    {
      Name = "k2hb_reconciliation_k2hb"
    }
  )
}

# Security group rules - local
resource "aws_security_group_rule" "k2hb_reconciliation_to_s3" {
  description       = "Allow k2hb reconciliation ECS to reach S3 (for Docker pull from ECR)"
  type              = "egress"
  prefix_list_ids   = [module.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.k2hb_reconciliation.id
}

resource "aws_security_group_rule" "k2hb_reconciliation_to_emr_master_zookeeper" {
  description              = "Allow outbound requests to HBase zookeeper"
  type                     = "egress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.master_sg_id
  security_group_id        = aws_security_group.k2hb_reconciliation.id
}

resource "aws_security_group_rule" "k2hb_reconciliation_to_emr_master" {
  count                    = length(var.hbase_emr_ports)
  description              = "Outbound requests to HBase master"
  type                     = "egress"
  from_port                = var.hbase_emr_ports[count.index]
  to_port                  = var.hbase_emr_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.master_sg_id
  security_group_id        = aws_security_group.k2hb_reconciliation.id
}

resource "aws_security_group_rule" "k2hb_reconciliation_to_emr_servers" {
  count                    = length(var.hbase_emr_ports)
  description              = "Outbound requests to HBase servers"
  type                     = "egress"
  from_port                = var.hbase_emr_ports[count.index]
  to_port                  = var.hbase_emr_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.slave_sg_id
  security_group_id        = aws_security_group.k2hb_reconciliation.id
}

resource "aws_security_group_rule" "k2hb_reconciliation_to_metadata_store" {
  description              = "Outbound requests to Metadata Store RDS"
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.metadata_store.id
  security_group_id        = aws_security_group.k2hb_reconciliation.id
}

# Security group rules - remote
resource "aws_security_group_rule" "emr_master_zookeeper_from_k2hb_reconciliation" {
  description              = "Allow inbound requests from k2hb reconciliation"
  type                     = "ingress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_reconciliation.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.master_sg_id
}

resource "aws_security_group_rule" "emr_master_from_k2hb_reconciliation" {
  count                    = length(var.hbase_emr_ports)
  description              = "Inbound requests from k2hb reconciliation"
  type                     = "ingress"
  from_port                = var.hbase_emr_ports[count.index]
  to_port                  = var.hbase_emr_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_reconciliation.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.master_sg_id
}

resource "aws_security_group_rule" "emr_servers_from_k2hb_reconciliation" {
  count                    = length(var.hbase_emr_ports)
  description              = "Inbound requests from k2hb reconciliation"
  type                     = "ingress"
  from_port                = var.hbase_emr_ports[count.index]
  to_port                  = var.hbase_emr_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_reconciliation.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.hbase_emr_security_groups.slave_sg_id
}

resource "aws_security_group_rule" "metadata_store_from_k2hb_reconciliation" {
  description              = "Inbound requests from k2hb reconciliation"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k2hb_reconciliation.id
  security_group_id        = aws_security_group.metadata_store.id
}
