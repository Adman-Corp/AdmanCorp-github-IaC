terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

resource "github_repository_ruleset" "this" {
  name        = var.ruleset.name
  repository  = var.repository_name
  target      = var.ruleset.target
  enforcement = var.ruleset.enforcement

  dynamic "conditions" {
    for_each = var.ruleset.target == "push" ? [] : [1]

    content {
      ref_name {
        include = var.ruleset.ref_name_include
        exclude = var.ruleset.ref_name_exclude
      }
    }
  }

  dynamic "bypass_actors" {
    for_each = var.ruleset.bypass_actors

    content {
      actor_id    = try(bypass_actors.value.actor_id, null)
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = try(bypass_actors.value.bypass_mode, null)
    }
  }

  rules {
    creation                = var.ruleset.target == "push" ? null : var.ruleset.creation
    update                  = var.ruleset.target == "push" ? null : var.ruleset.update
    deletion                = var.ruleset.target == "push" ? null : var.ruleset.deletion
    non_fast_forward        = var.ruleset.target == "push" ? null : var.ruleset.non_fast_forward
    required_linear_history = var.ruleset.target == "push" ? null : var.ruleset.required_linear_history
    required_signatures     = var.ruleset.target == "push" ? null : var.ruleset.required_signatures

    dynamic "pull_request" {
      for_each = var.ruleset.target == "push" || !var.ruleset.pull_request_required ? [] : [1]

      content {
        dismiss_stale_reviews_on_push    = var.ruleset.dismiss_stale_reviews_on_push
        require_code_owner_review        = var.ruleset.require_code_owner_review
        require_last_push_approval       = var.ruleset.require_last_push_approval
        required_approving_review_count  = var.ruleset.required_approving_review_count
        required_review_thread_resolution = var.ruleset.required_review_thread_resolution
        allowed_merge_methods            = var.ruleset.allowed_merge_methods
      }
    }

    dynamic "required_status_checks" {
      for_each = var.ruleset.target == "push" || length(var.ruleset.required_status_checks) == 0 ? [] : [1]

      content {
        strict_required_status_checks_policy = var.ruleset.strict_required_status_checks_policy
        do_not_enforce_on_create             = var.ruleset.do_not_enforce_on_create

        dynamic "required_check" {
          for_each = var.ruleset.required_status_checks

          content {
            context        = required_check.value.context
            integration_id = try(required_check.value.integration_id, null)
          }
        }
      }
    }

    dynamic "required_deployments" {
      for_each = var.ruleset.target == "push" || length(var.ruleset.required_deployments) == 0 ? [] : [1]

      content {
        required_deployment_environments = var.ruleset.required_deployments
      }
    }
  }
}
