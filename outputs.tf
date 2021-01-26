
output "asg_properties" {
  value = {
    max_counts = {
      k2hb_main_london           = var.k2hb_main_london_asg_max[local.environment]
      k2hb_main_dedicated_london = var.k2hb_main_dedicated_london_asg_max[local.environment]
      k2hb_equality_london       = var.k2hb_equality_london_asg_max[local.environment]
      k2hb_audit_london          = var.k2hb_audit_london_asg_max[local.environment]
    }
    prefixes = {
      k2hb_main_london           = aws_autoscaling_group.k2hb_main_london.name
      k2hb_main_dedicated_london = aws_autoscaling_group.k2hb_main_dedicated_london.name
      k2hb_equality_london       = aws_autoscaling_group.k2hb_equality_london.name
      k2hb_audit_london          = aws_autoscaling_group.k2hb_audit_london.name
    }
  }
}

output "security_group" {
  value = {
    k2hb_common = aws_security_group.k2hb_common.id
  }
}

output "k2hb_corporate_storage_coalesce_values" {
  value = {
    max_size_files = {
      main       = local.k2hb_main_corporate_storage_coalesce_max_files[local.environment]
      equalities = local.k2hb_equalities_corporate_storage_coalesce_max_files[local.environment]
      audit      = local.k2hb_audit_corporate_storage_coalesce_max_files[local.environment]
    }
    max_size_bytes = {
      main       = local.k2hb_main_corporate_storage_coalesce_max_size_bytes[local.environment]
      equalities = local.k2hb_equalities_corporate_storage_coalesce_max_size_bytes[local.environment]
      audit      = local.k2hb_audit_corporate_storage_coalesce_max_size_bytes[local.environment]
    }
  }
}
