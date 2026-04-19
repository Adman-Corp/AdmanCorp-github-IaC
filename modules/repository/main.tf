terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

resource "github_repository" "this" {
  name                        = var.repository.name
  description                 = var.repository.description
  homepage_url                = var.repository.homepage_url
  visibility                  = var.repository.visibility
  topics                      = var.repository.topics
  has_issues                  = var.repository.has_issues
  has_discussions             = var.repository.has_discussions
  has_projects                = var.repository.has_projects
  has_wiki                    = var.repository.has_wiki
  is_template                 = var.repository.is_template
  allow_merge_commit          = var.repository.allow_merge_commit
  allow_squash_merge          = var.repository.allow_squash_merge
  allow_rebase_merge          = var.repository.allow_rebase_merge
  allow_auto_merge            = var.repository.allow_auto_merge
  delete_branch_on_merge      = var.repository.delete_branch_on_merge
  allow_update_branch         = var.repository.allow_update_branch
  auto_init                   = var.repository.auto_init
  gitignore_template          = var.repository.gitignore_template
  license_template            = var.repository.license_template
  archived                    = var.repository.archived
  archive_on_destroy          = var.repository.archive_on_destroy
  vulnerability_alerts        = var.repository.vulnerability_alerts
  web_commit_signoff_required = var.repository.web_commit_signoff_required
}
