# Outputs for Terraform configuration

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.load_balancer_dns
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.load_balancer.load_balancer_zone_id
}

output "jenkins_instance_ip" {
  description = "Public IP of the Jenkins instance"
  value       = module.ec2.jenkins_instance_ip
}

output "app_instances_ips" {
  description = "Public IPs of the application instances"
  value       = module.ec2.app_instances_ips
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security.app_security_group_id
}

output "jenkins_security_group_id" {
  description = "ID of the Jenkins security group"
  value       = module.security.jenkins_security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}

