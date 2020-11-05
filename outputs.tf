
output "asg_properties" {
  value = {
    max_counts = {
      k2hb_main_ha_cluster = var.k2hb_main_asg_max[local.environment]
      k2hb_equality        = var.k2hb_equality_asg_max[local.environment]
      k2hb_audit_ireland   = var.k2hb_audit_ireland_asg_max[local.environment]
      k2hb_main_london     = var.k2hb_main_london_asg_max[local.environment]
      k2hb_equality_london = var.k2hb_equality_london_asg_max[local.environment]
      k2hb_audit_london    = var.k2hb_audit_london_asg_max[local.environment]
    }
    prefixes = {
      k2hb_main_ha_cluster = aws_autoscaling_group.k2hb_main_ha_cluster.name
      k2hb_equality        = aws_autoscaling_group.k2hb_equality.name
      k2hb_audit_ireland    = aws_autoscaling_group.k2hb_audit_ireland.name
      k2hb_main_london     = aws_autoscaling_group.k2hb_main_london.name
      k2hb_equality_london = aws_autoscaling_group.k2hb_equality_london.name
      k2hb_audit_london    = aws_autoscaling_group.k2hb_audit_london.name
    }
  }
}
