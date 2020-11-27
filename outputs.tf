
output "asg_properties" {
  value = {
    max_counts = {
      k2hb_main_ha_cluster        = var.k2hb_main_ireland_asg_max[local.environment]
      k2hb_main_dedicated_ireland = var.k2hb_main_dedicated_ireland_asg_max[local.environment]
      k2hb_equality               = var.k2hb_equality_ireland_asg_max[local.environment]
      k2hb_audit_ireland          = var.k2hb_audit_ireland_asg_max[local.environment]
      k2hb_main_london            = var.k2hb_main_london_asg_max[local.environment]
      k2hb_main_dedicated_london  = var.k2hb_main_dedicated_london_asg_max[local.environment]
      k2hb_equality_london        = var.k2hb_equality_london_asg_max[local.environment]
      k2hb_audit_london           = var.k2hb_audit_london_asg_max[local.environment]
    }
    prefixes = {
      k2hb_main_ha_cluster        = aws_autoscaling_group.k2hb_main_ha_cluster.name
      k2hb_main_dedicated_ireland = aws_autoscaling_group.k2hb_main_dedicated_ireland.name
      k2hb_equality               = aws_autoscaling_group.k2hb_equality.name
      k2hb_audit_ireland          = aws_autoscaling_group.k2hb_audit_ireland.name
      k2hb_main_london            = aws_autoscaling_group.k2hb_main_london.name
      k2hb_main_dedicated_london  = aws_autoscaling_group.k2hb_main_dedicated_london.name
      k2hb_equality_london        = aws_autoscaling_group.k2hb_equality_london.name
      k2hb_audit_london           = aws_autoscaling_group.k2hb_audit_london.name
    }
  }
}

output "k2hb_corporate_storage_coalesce_values" {
    value = {
        max_size_files = {
            main = local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]
            equalities = local.k2hb_equalities_corporate_storage_coalesce_max_files[local.environment]
            audit = local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]
        }
        max_size_bytes = {
            main = local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]
            equalities = local.k2hb_equalities_corporate_storage_coalesce_max_size_bytes[local.environment]
            audit = local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]
        }
    }
}
