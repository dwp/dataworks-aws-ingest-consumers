locals {
  k2hb_reconciliation_trimmer_image_url = "${local.account.management}.${module.vpc.ecr_dkr_domain_name}/kafka-to-hbase-reconciliation${var.k2hb_reconciliation_container_version}"
}

# AWS Batch Service IAM role
data "aws_iam_role" "aws_batch_service_role" {
  name = "aws_batch_service_role"
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

    security_group_ids = [aws_security_group.k2hb_reconciliation_trimmer_batch.id]
    subnets            = aws_subnet.business_data.*.id
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
