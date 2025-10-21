variable "users" {
  description = "List of Azure AD users"
  type = map(object({
    display_name = string
    # job_title = string
    # department = string
    # usage_location = string
  }))
}
