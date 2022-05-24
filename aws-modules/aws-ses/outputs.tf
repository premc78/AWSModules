output "domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.domain.arn
}

output "smtp_endpoint" {
  value = "email-smtp.${var.region}.amazonaws.com"
}

output "smtp_user" {
  value = aws_iam_access_key.ses.id
}

output "smtp_password" {
  value = aws_iam_access_key.ses.ses_smtp_password
}