output "managed_repositories" {
  description = "Repositories managed by this workspace."
  value = {
    for name, repository in module.repository : name => {
      full_name = repository.full_name
      html_url  = repository.html_url
      repo_id   = repository.repo_id
    }
  }
}

output "managed_rulesets" {
  description = "Repository rulesets attached by this workspace."
  value = {
    for key, ruleset in module.ruleset : key => {
      id         = ruleset.ruleset_id
      repository = ruleset.repository
      name       = ruleset.name
    }
  }
}
