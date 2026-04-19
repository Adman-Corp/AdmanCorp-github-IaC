variable "repository_name" {
  description = "Repository name that will receive the ruleset."
  type        = string
}

variable "ruleset" {
  description = "Normalized ruleset definition from config/rulesets.yaml."
  type = object({
    name                             = string
    target                           = string
    enforcement                      = string
    ref_name_include                 = list(string)
    ref_name_exclude                 = list(string)
    creation                         = optional(bool)
    update                           = optional(bool)
    deletion                         = optional(bool)
    non_fast_forward                 = optional(bool)
    required_linear_history          = optional(bool)
    required_signatures              = optional(bool)
    pull_request_required            = bool
    required_approving_review_count  = number
    dismiss_stale_reviews_on_push    = bool
    require_code_owner_review        = bool
    require_last_push_approval       = bool
    required_review_thread_resolution = bool
    allowed_merge_methods            = list(string)
    required_status_checks = list(object({
      context        = string
      integration_id = optional(number)
    }))
    strict_required_status_checks_policy = bool
    do_not_enforce_on_create             = bool
    required_deployments                 = list(string)
    bypass_actors = list(object({
      actor_type  = string
      actor_id    = optional(number)
      bypass_mode = optional(string)
    }))
  })

  validation {
    condition     = contains(["branch", "tag", "push"], var.ruleset.target)
    error_message = "Ruleset target must be branch, tag, or push."
  }

  validation {
    condition     = contains(["disabled", "active", "evaluate"], var.ruleset.enforcement)
    error_message = "Ruleset enforcement must be disabled, active, or evaluate."
  }
}
