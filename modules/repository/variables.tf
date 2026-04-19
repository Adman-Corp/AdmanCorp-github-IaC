variable "repository" {
  description = "Normalized repository definition from config/repositories.yaml."
  type = object({
    name                        = string
    description                 = optional(string)
    homepage_url                = optional(string)
    visibility                  = string
    topics                      = list(string)
    has_issues                  = bool
    has_discussions             = bool
    has_projects                = bool
    has_wiki                    = bool
    is_template                 = bool
    allow_merge_commit          = bool
    allow_squash_merge          = bool
    allow_rebase_merge          = bool
    allow_auto_merge            = bool
    delete_branch_on_merge      = bool
    allow_update_branch         = bool
    auto_init                   = bool
    gitignore_template          = optional(string)
    license_template            = optional(string)
    archived                    = bool
    archive_on_destroy          = bool
    vulnerability_alerts        = bool
    web_commit_signoff_required = bool
    rulesets                    = list(string)
  })

  validation {
    condition     = contains(["public", "private", "internal"], var.repository.visibility)
    error_message = "Repository visibility must be public, private, or internal."
  }
}
