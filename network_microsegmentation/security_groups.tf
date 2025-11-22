# Security Group for App allowing outbound to DB CIDR only
resource "aws_security_group" "app_sg" {
  count = local.create_vpcs

  name   = "app-sg"
  vpc_id = aws_vpc.app[0].id
  description = "App SG - allow outbound to DB only"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.db[0].cidr_block]
  }

  depends_on = [aws_vpc.app, aws_vpc.db]
}

# DB SG allowing MySQL only from App CIDR
resource "aws_security_group" "db_sg" {
  count = local.create_vpcs

  name   = "db-sg"
  vpc_id = aws_vpc.db[0].id
  description = "DB SG - allow MySQL from App VPC"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.app[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.app, aws_vpc.db]
}

# SG for interface endpoints
resource "aws_security_group" "endpoint_sg" {
  count = local.create_vpcs

  name        = "endpoint-sg"
  vpc_id      = aws_vpc.app[0].id
  description = "Endpoint SG for interface endpoints"

  depends_on = [aws_vpc.app]
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.app[0].cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
