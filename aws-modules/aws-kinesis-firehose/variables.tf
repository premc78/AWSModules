variable "splunk_elb_dns_alias_fqdn" {}
variable "splunk_smartstore_bucket_arn" {}
variable "splunk_smartstore_bucket_id" {}
variable "bootstrap_bucket" {}
variable "tags" {
  type = map(string)
}
variable "account_id" {}
variable "region" {}
variable "kms_key_arn" {}
variable "customer" {}
variable "project" {}