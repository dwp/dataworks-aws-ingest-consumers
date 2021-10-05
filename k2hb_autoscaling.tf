locals {
  k2hb_asgs_to_scale = {
    development = {}
    qa          = {}
    integration = {}
    preprod = {
      k2hb_main = {
        max_size = var.k2hb_main_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_main_london.name
      }
      k2hb_main_dedicated = {
        max_size = var.k2hb_main_dedicated_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_main_dedicated_london.name
      }
      k2hb_audit = {
        max_size = var.k2hb_audit_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_audit_london.name
      }
      k2hb_equalities = {
        max_size = var.k2hb_equality_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_equality_london.name
      }
    }
    production = {
      k2hb_main = {
        max_size = var.k2hb_main_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_main_london.name
      }
      k2hb_main_dedicated = {
        max_size = var.k2hb_main_dedicated_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_main_dedicated_london.name
      }
      k2hb_audit = {
        max_size = var.k2hb_audit_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_audit_london.name
      }
      k2hb_equalities = {
        max_size = var.k2hb_equality_london_asg_max[local.environment]
        asg_name = aws_autoscaling_group.k2hb_equality_london.name
      }
    }
  }

  cron_00_10_every_day                  = "10 00 * * *"
  cron_11_30_every_day_except_saturdays = "30 11 * * 1-5,7"
  cron_14_50_every_day_except_saturdays = "50 14 * * 1-5,7"
  cron_17_20_every_day_except_saturdays = "20 17 * * 1-5,7"
  cron_19_00_saturdays                  = "00 19 * * 6"
}

resource "aws_autoscaling_schedule" "scale_up_after_daily_maintenance_except_saturday" {
  for_each               = local.k2hb_asgs_to_scale[local.environment]
  scheduled_action_name  = "scale_up_after_daily_maintenance_${each.key}"
  min_size               = local.k2hb_asg_min[local.environment]
  max_size               = each.value.max_size
  desired_capacity       = each.value.max_size
  recurrence             = local.cron_17_20_every_day_except_saturdays
  autoscaling_group_name = each.value.asg_name
}

resource "aws_autoscaling_schedule" "scale_up_after_daily_export_except_saturday" {
  for_each               = local.k2hb_asgs_to_scale[local.environment]
  scheduled_action_name  = "scale_up_after_daily_export_except_saturday_${each.key}"
  min_size               = local.k2hb_asg_min[local.environment]
  max_size               = each.value.max_size
  desired_capacity       = each.value.max_size
  recurrence             = local.cron_11_30_every_day_except_saturdays
  autoscaling_group_name = each.value.asg_name
}

resource "aws_autoscaling_schedule" "scale_up_after_weekly_maintenance_on_saturday" {
  for_each               = local.k2hb_asgs_to_scale[local.environment]
  scheduled_action_name  = "scale_up_after_weekly_maintenance_on_saturday_${each.key}"
  min_size               = local.k2hb_asg_min[local.environment]
  max_size               = each.value.max_size
  desired_capacity       = each.value.max_size
  recurrence             = local.cron_19_00_saturdays
  autoscaling_group_name = each.value.asg_name
}

resource "aws_autoscaling_schedule" "scale_down_before_daily_maintenance_except_saturday" {
  for_each               = local.k2hb_asgs_to_scale[local.environment]
  scheduled_action_name  = "scale_down_before_daily_maintenance_${each.key}"
  min_size               = local.k2hb_asg_min[local.environment]
  max_size               = each.value.max_size
  desired_capacity       = 0
  recurrence             = local.cron_14_50_every_day_except_saturdays
  autoscaling_group_name = each.value.asg_name
}

resource "aws_autoscaling_schedule" "scale_down_before_daily_export" {
  for_each               = local.k2hb_asgs_to_scale[local.environment]
  scheduled_action_name  = "scale_down_before_daily_export_${each.key}"
  min_size               = local.k2hb_asg_min[local.environment]
  max_size               = each.value.max_size
  desired_capacity       = 0
  recurrence             = local.cron_00_10_every_day
  autoscaling_group_name = each.value.asg_name
}
