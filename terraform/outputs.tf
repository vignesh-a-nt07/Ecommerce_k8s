
output "rds_endpoint" {
  description = "RDS MySQL endpoint (hostname only)"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mysql.port
}

output "rds_database_name" {
  description = "RDS MySQL database name"
  value       = aws_db_instance.mysql.db_name
}

output "database_url" {
  description = "Complete MySQL database URL for application"
  value       = "mysql://${var.db_user}:${var.db_password}@${aws_db_instance.mysql.address}:${aws_db_instance.mysql.port}/${aws_db_instance.mysql.db_name}"
  sensitive   = true
}

########################################
# ECS / CI-CD critical outputs
########################################

########################################
# Networking outputs
########################################

output "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  value       = aws_subnet.private[*].id
}

########################################
# Optional / debugging
########################################

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}


output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

