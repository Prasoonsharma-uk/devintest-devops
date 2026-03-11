###############################################################################
# Root Module Outputs
###############################################################################

# --- Networking Outputs ---
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (application endpoint)"
  value       = module.networking.alb_dns_name
}

output "application_url" {
  description = "URL to access the Hello World application"
  value       = "http://${module.networking.alb_dns_name}"
}

# --- ECR Outputs ---
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# --- ECS Outputs ---
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "task_definition_family" {
  description = "Family of the ECS task definition"
  value       = module.ecs.task_definition_family
}
