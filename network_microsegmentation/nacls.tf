# Example NACL for App VPC: allow egress everywhere, restrict ingress to DB CIDR on MySQL port
resource "aws_network_acl" "app_acl" {
  count = local.create_vpcs

  vpc_id = aws_vpc.app[0].id
  tags = { Name = "App-NACL" }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = aws_vpc.db[0].cidr_block
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 200
    protocol   = "-1"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
