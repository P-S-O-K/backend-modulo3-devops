variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil de AWS CLI"
  type        = string
  default     = "terraform-modulo3"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "jenkins-modulo3"
}

variable "allowed_cidr" {
  description = "IP publica autorizada para acceder a Jenkins"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.allowed_cidr)) && endswith(var.allowed_cidr, "/32")
    error_message = "Introduce una IP publica en formato X.X.X.X/32."
  }
}