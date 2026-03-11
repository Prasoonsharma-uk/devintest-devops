# Development Environment Configuration
environment           = "dev"
project_name          = "hello-world-ecs"
aws_region            = "us-east-1"
vpc_cidr              = "10.0.0.0/16"
az_count              = 2
container_port        = 5000
task_cpu              = 256
task_memory           = 512
desired_count         = 1
min_capacity          = 1
max_capacity          = 2
image_tag_mutability  = "MUTABLE"
scan_on_push          = true
image_retention_count = 5
log_retention_days    = 7
container_insights    = false
