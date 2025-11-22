# Example VPC Endpoint for S3 (Gateway) and Interface Endpoint for DynamoDB/SSM etc.
resource "aws_vpc_endpoint" "s3_app" {
  count = local.create_vpcs

  vpc_id            = aws_vpc.app[0].id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [] # optional: add route table IDs if using custom route tables

  depends_on = [aws_vpc.app]
}

resource "aws_vpc_endpoint" "dynamodb_app" {
  count = local.create_vpcs

  vpc_id            = aws_vpc.app[0].id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.app_private[*].id
  security_group_ids = [aws_security_group.endpoint_sg[0].id]

  depends_on = [aws_vpc.app, aws_subnet.app_private, aws_security_group.endpoint_sg]
}
