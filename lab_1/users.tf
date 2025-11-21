resource "random_password" "user_password" {
  length  = 16
  special = true
}

resource "azuread_user" "ad_users" {
  for_each = var.users

  user_principal_name = "${each.key}@ferents1vladeslavgmail.onmicrosoft.com"
  display_name        = each.value.display_name
  mail_nickname       = each.key
  job_title           = "IT Lab Administrator"
  department          = "IT"
  usage_location      = "US"

  password              = random_password.user_password.result
  force_password_change = true
  account_enabled       = true
}

resource "azuread_invitation" "guest" {
  user_email_address = "vladyslav.ferents.22@pnu.edu.ua"
  redirect_url       = "https://portal.azure.com"

  message {
    body = "Welcome to Azure and our group project!"
  }
}