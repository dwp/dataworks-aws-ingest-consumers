locals {
  k2hb_reconciliation_trimmer_image_url = "${local.account.management}.${module.vpc.ecr_dkr_domain_name}/kafka-to-hbase-reconciliation${var.k2hb_reconciliation_container_version}"
}

resource "aws_iam_role" "ecs_instance_role_k2hb_reconciliation_trimmer_batch" {
  name = "ecs_instance_role_k2hb_reconciliation_trimmer_batch"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
}
EOF

  tags = merge(
    local.common_tags,
    { Name = "k2hb_reconciliation_trimmer" }
  )
}

resource "aws_iam_instance_profile" "ecs_instance_role_k2hb_reconciliation_trimmer_batch" {
  name = "ecs_instance_role_k2hb_reconciliation_trimmer_profile"
  role = aws_iam_role.ecs_instance_role_k2hb_reconciliation_trimmer_batch.name
}

resource "aws_batch_compute_environment" "k2hb_reconciliation_trimmer_batch" {
  compute_environment_name = "k2hb_reconciliation_trimmer"
  service_role             = data.aws_iam_role.aws_batch_service_role.arn
  type                     = "MANAGED"

  compute_resources {
    image_id      = var.ecs_hardened_ami_id
    instance_role = aws_iam_instance_profile.ecs_instance_role_k2hb_reconciliation_trimmer_batch.arn
    instance_type = ["optimal"]

    min_vcpus     = 0
    desired_vcpus = 0
    max_vcpus     = 8

    security_group_ids = [data.terraform_remote_state.ingest.outputs.ingestion_vpc.vpce_security_groups.k2hb_reconciliation_trimmer_batch.id]
    subnets            = data.terraform_remote_state.ingest.outputs.ingestion_subnets.id
    type               = "EC2"

    tags = merge(
      local.common_tags,
      {
        Name         = "k2hb-reconciliation-trimmer",
        Persistence  = "Ignore",
        AutoShutdown = "False",
      }
    )
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [compute_resources.0.desired_vcpus]
  }
}
