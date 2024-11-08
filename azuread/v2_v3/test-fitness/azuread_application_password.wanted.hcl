resource "azuread_application_password" "app" {
  application_id = azuread_application.app.id
  display_name   = "App Secret"
}

resource "azuread_application_password" "app_with_count" {
  count = 1

  application_id = azuread_application.app.id
  display_name   = "App Secret2"
}

locals {
  end_date            = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", azuread_application_password.app.end_date)
  end_date_with_count = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", azuread_application_password.app_with_count[0].end_date)
}