provider "github" {
  owner = var.github_owner
}

check "referenced_rulesets_exist" {
  assert {
    condition = alltrue([
      for repository_name, repository in local.repositories : alltrue([
        for ruleset_key in repository.rulesets : contains(keys(local.rulesets), ruleset_key)
      ])
    ])
    error_message = "Each repository rulesets entry must reference a key defined in config/rulesets.yaml."
  }
}

module "repository" {
  for_each = local.repositories

  source     = "./modules/repository"
  repository = each.value
}

module "ruleset" {
  for_each = local.repository_rulesets

  source          = "./modules/ruleset"
  repository_name = module.repository[each.value.repository_name].name
  ruleset         = each.value.ruleset
}
