resource "random_password" "user_password" {
  length  = 16
  special = true
}

resource "azuread_user" "creat_user" {
    for_each = var.users

    user_principal_name = "${each.key}@yourtenant.onmicrosoft.com"
    display_name = each.value.display_name
    mail_nickname = each.key
    job_title = "IT Lab Administrator"
    department = "IT"
    usage_location = "US"

    password              = random_password.user_password.result
    force_password_change = true
    account_enabled       = true
}

resource "azuread_invitation" "guest"{
    user_email = "vladyslav.ferents.22@pnu.edu.ua"
    invite_redirect_url = "https://portal.azure.com"
    invited_user_display_name = "Vladyslav Guest"
    message = "Welcome to Azure and our group project"

    send_invitation_message = true
}