output "url" {
  value = aws_ecr_repository.ecr_repo.repository_url
}

output "arn" {
  value = aws_ecr_repository.ecr_repo.arn
}