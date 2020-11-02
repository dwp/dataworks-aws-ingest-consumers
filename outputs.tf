
output "asg_properties" {
  value = {
    max_counts = {
      k2hb_main_ha_cluster   = var.k2hb_main_ha_cluster_asg_max[local.environment]
      k2hb_equality          = var.k2hb_equality_asg_max[local.environment]
    }
    prefixes = {
      k2hb_main_ha_cluster   = aws_autoscaling_group.k2hb_main_ha_cluster.name
      k2hb_equality          = aws_autoscaling_group.k2hb_equality.name
    }
  }
}
