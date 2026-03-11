###############################################################################
# Root Module - Orchestrates all infrastructure modules
###############################################################################

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# --- Networking Module ---
module "networking" {
  source = "./modules/networking"

  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  az_count       = var.az_count
  container_port = var.container_port
  tags           = local.common_tags
}

# --- ECR Module ---
module "ecr" {
  source = "./modules/ecr"

  project_name          = var.project_name
  environment           = var.environment
  image_tag_mutability  = var.image_tag_mutability
  scan_on_push          = var.scan_on_push
  image_retention_count = var.image_retention_count
  tags                  = local.common_tags
}

# --- ECS Module ---
module "ecs" {
  source = "./modules/ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  ecr_repository_url          = module.ecr.repository_url
  image_tag                   = var.image_tag
  container_port              = var.container_port
  task_cpu                    = var.task_cpu
  task_memory                 = var.task_memory
  desired_count               = var.desired_count
  min_capacity                = var.min_capacity
  max_capacity                = var.max_capacity
  private_subnet_ids          = module.networking.private_subnet_ids
  ecs_tasks_security_group_id = module.networking.ecs_tasks_security_group_id
  target_group_arn            = module.networking.target_group_arn
  log_retention_days          = var.log_retention_days
  container_insights          = var.container_insights
  tags                        = local.common_tags
}
