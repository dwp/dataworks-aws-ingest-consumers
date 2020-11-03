# TODO - import the main and audit log groups here

# Current as at Aug 2020 - don't change the resource or logical name!
resource "aws_cloudwatch_log_group" "k2hb_ec2_audit_logs" {
  name              = local.k2hb_ec2_audit_logs_name
  retention_in_days = 180
  tags              = local.common_tags
}
