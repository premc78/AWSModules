resource "aws_ses_domain_identity" "domain" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.domain.domain
}

resource "aws_ses_domain_mail_from" "from" {
  domain           = aws_ses_domain_identity.domain.domain
  mail_from_domain = "mail.${var.domain}"
}

resource "aws_route53_record" "domain_amazonses_verification_record" {
  count   = var.zone_id != null ? 1 : 0
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "3600"
  records = concat([aws_ses_domain_identity.domain.verification_token], var.ses_records)
}

resource "aws_route53_record" "domain_amazonses_dkim_record" {
  count   = var.zone_id != null ? 3 : 0
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mail_from_domain_spf_record" {
  count   = var.zone_id != null ? 1 : 0
  zone_id = var.zone_id
  name    = aws_ses_domain_mail_from.from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "domain_spf_record" {
  count   = var.zone_id != null ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "domain_mx_out_record" {
  count   = var.zone_id != null ? 1 : 0
  zone_id = var.zone_id
  name    = aws_ses_domain_mail_from.from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

resource "aws_route53_record" "domain_mx_in_record" {
  count   = var.zone_id != null ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.region}.amazonses.com"]
}

resource "aws_route53_record" "domain_dmarc_record" {
  count   = var.zone_id != null ? 1 : 0
  zone_id = var.zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=reject; rua=mailto:reports@${var.domain};"]
}

resource "aws_iam_user" "ses" {
  name = "ses-email-user-${var.project}"
  tags = var.tags
}

resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.ses.name
}

data "aws_iam_policy_document" "send_email" {
  policy_id = "ses-send-email-${var.project}"
  statement {
    sid = "AuthorizeSendMail"
    actions = [
      "SES:SendEmail",
      "SES:SendRawEmail"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "send_email" {
  policy = data.aws_iam_policy_document.send_email.json
  user   = aws_iam_user.ses.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ses.amazonaws.com"]
      type        = "Service"
    }
  }
}