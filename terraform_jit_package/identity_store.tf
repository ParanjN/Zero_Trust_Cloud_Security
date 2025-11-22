resource "aws_identitystore_user" "alice" {
  identity_store_id = var.identity_store_id
  user_name         = "alice"
  display_name      = "Alice Admin"
  
  name {
    given_name  = "Alice"
    family_name = "Admin"
  }
  
  emails {
    value   = "alice+terraform@example.com"
    primary = true
  }
}

resource "aws_identitystore_user" "bob" {
  identity_store_id = var.identity_store_id
  user_name         = "bob"
  display_name      = "Bob DevOps"
  
  name {
    given_name  = "Bob"
    family_name = "DevOps"
  }
  
  emails {
    value   = "bob+terraform@example.com"
    primary = true
  }
}

resource "aws_identitystore_group" "admins" {
  identity_store_id = var.identity_store_id
  display_name      = "Admins"
  description       = "Admin group"
}

resource "aws_identitystore_group" "devops" {
  identity_store_id = var.identity_store_id
  display_name      = "DevOps"
  description       = "DevOps group"
}

resource "aws_identitystore_group_membership" "alice_admins" {
  identity_store_id = var.identity_store_id
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = aws_identitystore_user.alice.user_id
}

resource "aws_identitystore_group_membership" "bob_devops" {
  identity_store_id = var.identity_store_id
  group_id          = aws_identitystore_group.devops.group_id
  member_id         = aws_identitystore_user.bob.user_id
}
