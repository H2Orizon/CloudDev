resource "azuread_group" "IT_Lab_Administrators" {
  display_name = "IT-Lab-Administrators"
  description  = "Administrators that manage the IT lab"

  owners = [data.azuread_client_config.current.object_id]

  security_enabled   = true
  assignable_to_role = false
}

resource "azuread_group_member" "ad_users" {
  for_each = azuread_user.ad_users

  group_object_id  = azuread_group.IT_Lab_Administrators.id
  member_object_id = each.value.id
}
resource "azuread_group_member" "ad_guest" {
  group_object_id  = azuread_group.IT_Lab_Administrators.id
  member_object_id = azuread_invitation.guest.invited_user_id
}