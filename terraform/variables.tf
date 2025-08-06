# Variables for Terraform configuration

variable "aws_region" {
  description = "us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "DevOps React"
  type        = string
  default     = "react-devops-pipeline"
}

variable "environment" {
  description = "DEV"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "DevOps-Team"
  type        = string
  default     = "DevOps-Team"
}

variable "vpc_cidr" {
  description = "10.0.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = ["10.0.10.0/24", "10.0.20.0/24"] 
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "allowed_cidr_blocks" {
  description = ["0.0.0.0/0"]
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "t3.micro"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "user_management"
  type        = string
  default     = "react-app-keypair"
}

variable "min_size" {
  description = 1
  type        = number
  default     = 1
}

variable "max_size" {
  description = 3
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = 2
  type        = number
  default     = 2
}

variable "docker_image" {
  description = "nginx:latest"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = 80
  type        = number
  default     = 80
}

