locals {
  # Use the variable directly to avoid plan-time dependency issues
  tgw_enabled = var.enable_tgw ? 1 : 0
}

# Create the Transit Gateway only if enabled and VPCs exist
resource "aws_ec2_transit_gateway" "tgw" {
  count = local.tgw_enabled

  description = "Central Transit Gateway for micro-segmentation lab"
  tags = { Name = "Central-TGW" }
}

# Attach App VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "app_attach" {
  count = local.tgw_enabled > 0 && local.create_vpcs > 0 ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id            = aws_vpc.app[0].id
  subnet_ids        = [for subnet in aws_subnet.app_private : subnet.id]
  
  tags = { Name = "tgw-attach-app" }

  depends_on = [
    aws_vpc.app,
    aws_subnet.app_private,
    aws_ec2_transit_gateway.tgw
  ]
}

# Attach DB VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "db_attach" {
  count = local.tgw_enabled > 0 && local.create_vpcs > 0 ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id            = aws_vpc.db[0].id
  subnet_ids        = [for subnet in aws_subnet.db_private : subnet.id]
  
  tags = { Name = "tgw-attach-db" }

  depends_on = [
    aws_vpc.db,
    aws_subnet.db_private,
    aws_ec2_transit_gateway.tgw
  ]
}

# Attach Logging VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "logging_attach" {
  count = local.tgw_enabled > 0 && local.create_vpcs > 0 ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id            = aws_vpc.logging[0].id
  subnet_ids        = [for subnet in aws_subnet.logging_private : subnet.id]
  
  tags = { Name = "tgw-attach-logging" }

  depends_on = [
    aws_vpc.logging,
    aws_subnet.logging_private,
    aws_ec2_transit_gateway.tgw
  ]
}
