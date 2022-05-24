resource "aws_security_group_rule" "rule" {
  type                     = var.type
  from_port                = var.ports[count.index]
  to_port                  = var.ports[count.index]
  protocol                 = var.protocol
  source_security_group_id = var.source_security_group_id
  cidr_blocks              = var.cidr_blocks
  security_group_id        = var.security_group_id
  description              = var.description
  count                    = length(var.ports)
}
