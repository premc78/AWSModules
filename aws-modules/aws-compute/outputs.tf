output "splunk_instance_id" {
  value = aws_instance.splunk_instance.*.id
}

output "splunk_instance_ip" {
  value = aws_instance.splunk_instance.*.public_ip
}

output "instance_ip" {
  value = aws_instance.splunk_instance.*.public_ip
}