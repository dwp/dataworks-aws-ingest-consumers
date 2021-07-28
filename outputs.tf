
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

output "k2hb_reconciliation" {
  value = {
    task_configs = local.k2hb_reconciliation_task_configs
    task_counts = {
      ucfs_reconciliation     = local.k2hb_reconciliation_task_configs.ucfs_reconciliation.task_count[local.environment]
      equality_reconciliation = local.k2hb_reconciliation_task_configs.equality_reconciliation.task_count[local.environment]
      audit_reconciliation    = local.k2hb_reconciliation_task_configs.audit_reconciliation.task_count[local.environment]
    }
    cluster_names = {
      ucfs_reconciliation     = data.terraform_remote_state.common.outputs.ecs_cluster_main.id
      equality_reconciliation = data.terraform_remote_state.common.outputs.ecs_cluster_main.id
      audit_reconciliation    = data.terraform_remote_state.common.outputs.ecs_cluster_main.id
    }
    service_names = {
      ucfs_reconciliation     = local.k2hb_reconciliation_names.ucfs_reconciliation
      equality_reconciliation = local.k2hb_reconciliation_names.equality_reconciliation
      audit_reconciliation    = local.k2hb_reconciliation_names.audit_reconciliation
    }
    partition_counts = {
      ucfs_reconciliation     = local.k2hb_reconciliation_task_configs.ucfs_reconciliation.table_partitions[local.environment]
      equality_reconciliation = local.k2hb_reconciliation_task_configs.equality_reconciliation.table_partitions[local.environment]
      audit_reconciliation    = local.k2hb_reconciliation_task_configs.audit_reconciliation.table_partitions[local.environment]
    }
  }
}

output "locals" {
  value = {
    k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records         = local.k2hb_reconciliation_metric_name_number_of_successfully_reconciled_records
    k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation     = local.k2hb_reconciliation_metric_name_number_of_records_which_failed_reconciliation
    k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed = local.k2hb_reconciliation_trimmer_metric_name_number_of_records_which_have_been_trimmed
    cw_k2hb_reconciliation_ucfs_namespace                                             = local.cw_k2hb_reconciliation_ucfs_namespace
    cw_k2hb_reconciliation_equality_namespace                                         = local.cw_k2hb_reconciliation_equality_namespace
    cw_k2hb_reconciliation_audit_namespace                                            = local.cw_k2hb_reconciliation_audit_namespace
    cw_k2hb_reconciliation_trimmer_namespace                                          = local.cw_k2hb_reconciliation_trimmer_namespace
  }
}

output "batch_corporate_storage_coalescer" {
  value = aws_batch_job_queue.batch_corporate_storage_coalescer
}

output "batch_corporate_storage_coalescer_long_running" {
  value = aws_batch_job_queue.batch_corporate_storage_coalescer_long_running
}
