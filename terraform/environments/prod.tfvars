# Production Environment Configuration
environment           = "prod"
project_name          = "hello-world-ecs"
aws_region            = "us-east-1"
vpc_cidr              = "10.1.0.0/16"
az_count              = 3
container_port        = 5000
task_cpu              = 512
task_memory           = 1024
desired_count         = 2
min_capacity          = 2
max_capacity          = 6
image_tag_mutability  = "IMMUTABLE"
scan_on_push          = true
image_retention_count = 20
log_retention_days    = 90
container_insights    = true
