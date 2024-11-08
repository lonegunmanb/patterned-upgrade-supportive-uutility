transform regex_replace_expression azuread_application_password_end_date {
  for_each    = var.azuread_application_password_toggle ? ["azuread_application_password_toggle"] : []
  regex       = "(^|[^d]$|[^a]d$|[^t]da$|[^a]dat$|[^.]data$)azuread_application_password\\.(\\s*\\r?\\n\\s*)?(\\w+)(\\[\\s*[^]]+\\s*\\])?(\\.)(\\s*\\r?\n\\s*)?end_date([^s]|$)"
  replacement = "formatdate(\"YYYY-MM-DD'T'hh:mm:ssZ\", azuread_application_password.$${1}$${2}$${3}$${4}$${5}end_date)"
}

