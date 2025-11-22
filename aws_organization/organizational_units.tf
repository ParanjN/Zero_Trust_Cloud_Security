# Look up existing organizational units
data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

locals {
  # Standard OU configuration
  ou_config = {
    "security" = "Security"
    "logging"  = "Logging"
    "sandbox"  = "Sandbox"
    "prod"     = "Prod"
    "devtest"  = "DevTest"
  }

  # Map of existing OUs by both original name and lowercase name
  existing_ous_raw = {
    for ou in data.aws_organizations_organizational_units.root_ous.children :
    ou.name => ou.id
  }

  # Create a mapping of standardized names to existing OUs
  existing_ou_map = merge(
    # Map by exact name match
    {
      for name, id in local.existing_ous_raw :
      lower(name) => id
      if contains(values(local.ou_config), name)
    },
    # Map by case-insensitive match
    {
      for name, display_name in local.ou_config :
      name => local.existing_ous_raw[
        [for existing_name in keys(local.existing_ous_raw) : 
         existing_name if lower(existing_name) == lower(display_name)][0]
      ]
      if contains([for existing_name in keys(local.existing_ous_raw) : 
                  lower(existing_name)], lower(display_name))
    }
  )

  # List of OUs to create (only those that don't exist)
  ous_to_create = {
    for name, display_name in local.ou_config :
    name => display_name
    if !contains(keys(local.existing_ou_map), name)
  }
}

# Create only non-existing organizational units
resource "aws_organizations_organizational_unit" "ou" {
  for_each = local.ous_to_create

  name      = each.value
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

# Combine existing and new OUs for reference
locals {
  all_ous = merge(
    local.existing_ou_map,
    {
      for name, _ in aws_organizations_organizational_unit.ou :
      name => aws_organizations_organizational_unit.ou[name].id
    }
  )
}