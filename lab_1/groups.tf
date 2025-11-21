resource "azuread_group" "IT_Lab_Administrators" {
  display_name       = "IT-Lab-Administrators"
  description        = "Administrators that manage the IT lab"
  owners             = [data.azuread_client_config.current.object_id]
  security_enabled   = true
  assignable_to_role = false
}

resource "azuread_group_member" "ad_users" {
  for_each = azuread_user.ad_users

  group_object_id  = regex("([0-9a-fA-F-]{36})", azuread_group.IT_Lab_Administrators.id)[0]
  member_object_id = regex("([0-9a-fA-F-]{36})", each.value.id)[0]
}

data "azuread_user" "guest" {
  mail = "vladyslav.ferents.22@pnu.edu.ua"
  depends_on = [azuread_invitation.guest]
}

resource "azuread_group_member" "guest_user" {
  depends_on = [data.azuread_user.guest]

  group_object_id  = regex("([0-9a-fA-F-]{36})", azuread_group.IT_Lab_Administrators.id)[0]
  member_object_id = regex("([0-9a-fA-F-]{36})", data.azuread_user.guest.id)[0]
}