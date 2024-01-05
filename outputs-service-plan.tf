output "service_plan_id" {
  description = "ID of the created Service Plan"
  value       = local.service_plan_id
}

output "os_type" {
  description = "The OS type for the Functions to be hosted in this plan."
  value       = var.os_type
}
