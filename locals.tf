locals {
  repositories_file = yamldecode(file("${path.module}/config/repositories.yaml"))
  rulesets_file     = yamldecode(file("${path.module}/config/rulesets.yaml"))

  repository_defaults = merge(
    {
      description               = null
      homepage_url              = null
      visibility                = "private"
      topics                    = []
      has_issues                = true
      has_discussions           = false
      has_projects              = false
      has_wiki                  = false
      is_template               = false
      allow_merge_commit        = false
      allow_squash_merge        = true
      allow_rebase_merge        = false
      allow_auto_merge          = true
      delete_branch_on_merge    = true
      allow_update_branch       = true
      auto_init                 = true
      gitignore_template        = null
      license_template          = null
      archived                  = false
      archive_on_destroy        = true
      vulnerability_alerts      = true
      web_commit_signoff_required = true
      rulesets                  = []
    },
    try(local.repositories_file.defaults, {})
  )

  repositories = {
    for repository in try(local.repositories_file.repositories, []) : repository.name => merge(
      local.repository_defaults,
      repository,
      {
        topics   = try(repository.topics, local.repository_defaults.topics)
        rulesets = try(repository.rulesets, local.repository_defaults.rulesets)
      }
    )
  }

  ruleset_defaults = merge(
    {
      target                           = "branch"
      enforcement                      = "active"
      ref_name_include                 = ["~DEFAULT_BRANCH"]
      ref_name_exclude                 = []
      creation                         = null
      update                           = null
      deletion                         = true
      non_fast_forward                 = true
      required_linear_history          = true
      required_signatures              = false
      pull_request_required            = true
      required_approving_review_count  = 1
      dismiss_stale_reviews_on_push    = true
      require_code_owner_review        = false
      require_last_push_approval       = false
      required_review_thread_resolution = true
      allowed_merge_methods            = ["squash"]
      required_status_checks           = []
      strict_required_status_checks_policy = true
      do_not_enforce_on_create         = false
      required_deployments             = []
      bypass_actors                    = []
    },
    try(local.rulesets_file.defaults, {})
  )

  rulesets = {
    for ruleset in try(local.rulesets_file.rulesets, []) : ruleset.key => merge(local.ruleset_defaults, ruleset)
  }

  repository_rulesets = {
    for attachment in flatten([
      for repository_name, repository in local.repositories : [
        for ruleset_key in repository.rulesets : {
          repository_name = repository_name
          ruleset_key     = ruleset_key
          ruleset         = local.rulesets[ruleset_key]
        }
      ]
    ]) : "${attachment.repository_name}:${attachment.ruleset_key}" => attachment
  }
}
