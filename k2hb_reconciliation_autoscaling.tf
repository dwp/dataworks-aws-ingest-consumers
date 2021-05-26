locals {
  k2hb_reconcilers_to_scale = flatten([
    for reconciler_name, reconciler_service_names in local.all_reconcilers[local.environment] : [
      for reconciler_service_name in reconciler_service_names : {
        reconciler_name = reconciler_name
        max_size        = local.k2hb_reconciliation_task_configs[reconciler_name].task_count[local.environment]
        cluster_name    = data.terraform_remote_state.common.outputs.ecs_cluster_main.id
        service_name    = reconciler_service_name
      }
    ]
  ])

  all_reconcilers = {
    development = {
      ucfs_reconciliation     = [for service in aws_ecs_service.k2hb_reconciliation_ucfs : service.name]
      audit_reconciliation    = [for service in aws_ecs_service.k2hb_reconciliation_audit : service.name]
      equality_reconciliation = [for service in aws_ecs_service.k2hb_reconciliation_equality : service.name]
    }
    qa = {
      ucfs_reconciliation     = [for service in aws_ecs_service.k2hb_reconciliation_ucfs : service.name]
      audit_reconciliation    = [for service in aws_ecs_service.k2hb_reconciliation_audit : service.name]
      equality_reconciliation = [for service in aws_ecs_service.k2hb_reconciliation_equality : service.name]
    }
    integration = {
      ucfs_reconciliation     = [for service in aws_ecs_service.k2hb_reconciliation_ucfs : service.name]
      audit_reconciliation    = [for service in aws_ecs_service.k2hb_reconciliation_audit : service.name]
      equality_reconciliation = [for service in aws_ecs_service.k2hb_reconciliation_equality : service.name]
    }
    preprod = {
      ucfs_reconciliation     = [for service in aws_ecs_service.k2hb_reconciliation_ucfs : service.name]
      audit_reconciliation    = [for service in aws_ecs_service.k2hb_reconciliation_audit : service.name]
      equality_reconciliation = [for service in aws_ecs_service.k2hb_reconciliation_equality : service.name]
    }
    production = {
      equality_reconciliation = [for service in aws_ecs_service.k2hb_reconciliation_equality : service.name]
    }
  }

  app_cron_17_20_every_day                  = "20 17 * * ? *"
  app_cron_09_30_every_day_except_saturdays = "30 09 ? * 1-5,7 *"
  app_cron_14_50_every_day                  = "50 14 * * ? *"
  app_cron_00_45_every_day                  = "45 00 * * ? *"
  app_cron_03_00_saturdays                  = "00 03 ? * 6 *"
}

resource "aws_appautoscaling_target" "k2hb_reconciler_desired_count" {
  for_each = {
    for reconciler in local.k2hb_reconcilers_to_scale : "${reconciler.reconciler_name}_${reconciler.service_name}" => reconciler
  }
  max_capacity       = each.value.max_size
  min_capacity       = 0
  resource_id        = "service/${each.value.cluster_name}/${each.value.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_scheduled_action" "k2hb_reconciler_scale_down_before_weekly_maintenance" {
  for_each           = aws_appautoscaling_target.k2hb_reconciler_desired_count
  name               = "k2hb_reconciler_scale_down_before_weekly_maintenance_${each.key}"
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  schedule           = "cron(${local.app_cron_03_00_saturdays})"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "k2hb_reconciler_scale_down_before_daily_export" {
  for_each           = local.environment == "production" ? aws_appautoscaling_target.k2hb_reconciler_desired_count : {}
  name               = "k2hb_reconciler_scale_down_before_daily_export_${each.key}"
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  schedule           = "cron(${local.app_cron_00_45_every_day})"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "k2hb_reconciler_scale_down_before_daily_maintenance" {
  for_each           = local.environment == "production" ? aws_appautoscaling_target.k2hb_reconciler_desired_count : {}
  name               = "k2hb_reconciler_scale_down_before_daily_maintenance_${each.key}"
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  schedule           = "cron(${local.app_cron_14_50_every_day})"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "k2hb_reconciler_scale_up_after_daily_export_except_saturday" {
  for_each           = local.environment == "production" ? aws_appautoscaling_target.k2hb_reconciler_desired_count : {}
  name               = "k2hb_reconciler_scale_up_after_daily_export_${each.key}"
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  schedule           = "cron(${local.app_cron_09_30_every_day_except_saturdays})"

  scalable_target_action {
    min_capacity = each.value.max_capacity
    max_capacity = each.value.max_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "k2hb_reconciler_scale_up_after_daily_maintenance" {
  for_each           = local.environment == "production" ? aws_appautoscaling_target.k2hb_reconciler_desired_count : {}
  name               = "k2hb_reconciler_scale_up_after_daily_maintenance_${each.key}"
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  schedule           = "cron(${local.app_cron_17_20_every_day})"

  scalable_target_action {
    min_capacity = each.value.max_capacity
    max_capacity = each.value.max_capacity
  }
}
