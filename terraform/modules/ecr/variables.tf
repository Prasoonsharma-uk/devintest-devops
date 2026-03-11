variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "image_retention_count" {
  description = "Number of images to retain in the repository"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
