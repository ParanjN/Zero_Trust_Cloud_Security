# Create one private subnet per AZ for each VPC (if AZs provided) otherwise create a single subnet each
locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : [data.aws_availability_zones.available.names[0]]
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "app_private" {
  count = local.create_vpcs > 0 ? length(local.azs) : 0
  vpc_id = aws_vpc.app[0].id
  cidr_block = cidrsubnet(aws_vpc.app[0].cidr_block, 8, count.index)
  availability_zone = local.azs[count.index]
  tags = { Name = "App-Private-${count.index}" }

  depends_on = [aws_vpc.app]
}

resource "aws_subnet" "db_private" {
  count = local.create_vpcs > 0 ? length(local.azs) : 0
  vpc_id = aws_vpc.db[0].id
  cidr_block = cidrsubnet(aws_vpc.db[0].cidr_block, 8, count.index)
  availability_zone = local.azs[count.index]
  tags = { Name = "DB-Private-${count.index}" }

  depends_on = [aws_vpc.db]
}

resource "aws_subnet" "logging_private" {
  count = local.create_vpcs > 0 ? length(local.azs) : 0
  vpc_id = aws_vpc.logging[0].id
  cidr_block = cidrsubnet(aws_vpc.logging[0].cidr_block, 8, count.index)
  availability_zone = local.azs[count.index]
  tags = { Name = "Logging-Private-${count.index}" }

  depends_on = [aws_vpc.logging]
}
