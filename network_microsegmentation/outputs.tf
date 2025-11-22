output "app_vpc_id" {
  value = try(aws_vpc.app[0].id, null)
}

output "db_vpc_id" {
  value = try(aws_vpc.db[0].id, null)
}

output "logging_vpc_id" {
  value = try(aws_vpc.logging[0].id, null)
}

output "tgw_id" {
  value = try(aws_ec2_transit_gateway.tgw[0].id, null)
  description = "ID of the Transit Gateway if enabled and created"
}

output "app_private_subnet_ids" {
  value = try(aws_subnet.app_private[*].id, [])
}

output "db_private_subnet_ids" {
  value = aws_subnet.db_private[*].id
}

output "logging_private_subnet_ids" {
  value = aws_subnet.logging_private[*].id
}
