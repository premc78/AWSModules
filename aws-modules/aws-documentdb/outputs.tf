output "master_username" {
  value       = aws_docdb_cluster.default.master_username
  description = "Username for the master DB user"
}

output "cluster_name" {
  value       = aws_docdb_cluster.default.cluster_identifier
  description = "Cluster Identifier"
}

output "arn" {
  value       = aws_docdb_cluster.default.arn
  description = "Amazon Resource Name (ARN) of the cluster"
}

output "endpoint" {
  value       = aws_docdb_cluster.default.endpoint
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = aws_docdb_cluster.default.reader_endpoint
  description = "A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "security_group_id" {
  description = "ID of the DocumentDB cluster Security Group"
  value       = aws_security_group.default.id
}

output "security_group_arn" {
  description = "ARN of the DocumentDB cluster Security Group"
  value       = aws_security_group.default.arn
}

output "security_group_name" {
  description = "Name of the DocumentDB cluster Security Group"
  value       = aws_security_group.default.name
}