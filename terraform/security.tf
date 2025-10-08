# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Create Security Group
resource "aws_security_group" "allow_anywhere" {
    name = "allow_anywhere"
    vpc_id = data.aws_vpc.default.id
}

locals {
    ingress_rules = [
        { port = 22,  desc = "SSH" },
        { port = 80,  desc = "HTTP" },
        { port = 443, desc = "HTTPS" }
    ]

}

# Allow port
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id = aws_security_group.allow_anywhere.id
  for_each =  { for rule in local.ingress_rules : tostring(rule.port) => rule }
  ip_protocol = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value.port
  to_port           = each.value.port
  description       = each.value.desc
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.allow_anywhere.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}
