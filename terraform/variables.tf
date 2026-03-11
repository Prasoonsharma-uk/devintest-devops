###############################################################################
# Root Module Variables
###############################################################################

variable "project_name" {
  description = "Name of the project, used as a prefix for all resources"
  type        = string
  default     = "hello-world-ecs"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

# --- Networking Variables ---
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

# --- Container Variables ---
variable "container_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 5000
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

# --- ECS Variables ---
variable "task_cpu" {
  description = "CPU units for the ECS task (1 vCPU = 1024)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory (MiB) for the ECS task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks running"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto scaling"
  type        = number
  default     = 4
}

# --- ECR Variables ---
variable "image_tag_mutability" {
  description = "ECR image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push to ECR"
  type        = bool
  default     = true
}

variable "image_retention_count" {
  description = "Number of images to retain in ECR"
  type        = number
  default     = 10
}

# --- Logging Variables ---
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS cluster"
  type        = bool
  default     = true
}
