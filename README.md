# AdmanCorp GitHub IaC

Terraform repository for managing AdmanCorp GitHub repositories and reusable repository rulesets from versioned YAML data.

## Scope

Phase 1 covers:

- Repository creation and baseline settings for newly managed repositories.
- Reusable repository rulesets attached by key from repository definitions.

Explicitly out of scope for now:

- Importing or retrofitting existing repositories.
- Teams, memberships, secrets, variables, webhooks, and GitHub Apps.
- GitHub-managed secrets, variables, and any post-bootstrap deployment workflows beyond Terraform itself.

## Repository Layout

```text
.
|-- config/
|   |-- repositories.yaml
|   `-- rulesets.yaml
|-- modules/
|   |-- repository/
|   `-- ruleset/
|-- locals.tf
|-- main.tf
|-- outputs.tf
|-- variables.tf
`-- versions.tf
```

## Prerequisites

- Terraform 1.6 or newer.
- A Terraform Cloud organization and workspace for this repository.
- GitHub credentials with permission to manage the target organization.
- A Terraform Cloud workspace configured for `Local` execution mode.

## Terraform Cloud

The root module uses an empty `cloud` block in [versions.tf](/home/yadman/Github/AdmanCorp-github-IaC/versions.tf). The GitHub Actions workflow supplies the Terraform Cloud organization and workspace through environment variables so the same configuration can be reused across environments.

This repository is set up for state in Terraform Cloud and execution in GitHub Actions:

- One Terraform Cloud workspace for this repository.
- Terraform Cloud workspace execution mode set to `Local`.
- GitHub Actions runs `terraform init`, `plan`, and `apply`.
- Terraform Cloud provides remote state and locking.

Set these GitHub repository settings for the workflow:

- Secret `TF_API_TOKEN`: Terraform Cloud user or team token with access to the target workspace.
- Secret `TF_CLOUD_ORGANIZATION`: Terraform Cloud organization name.
- Secret `TF_WORKSPACE`: Terraform Cloud workspace name.
- Variable `GH_OWNER`: GitHub organization to manage.
- Secret `GH_PROVIDER_TOKEN`: GitHub token exposed to the job as `GITHUB_TOKEN` for the Terraform GitHub provider.

Important: in Terraform Cloud `Local` execution mode, workspace Terraform variables and variable sets are not used to execute the run. The workflow environment is the source of truth for runtime credentials and input variables.

## GitHub Actions

The workflow in [.github/workflows/terraform.yml](/home/yadman/Github/AdmanCorp-github-IaC/.github/workflows/terraform.yml) does the following:

- On pull requests, runs `terraform init`, `fmt -check`, `validate`, and `plan`, then posts the rendered plan as a PR comment.
- On pushes to `main`, runs the same checks and then applies the saved plan.
- On manual dispatch, runs the same pipeline so you can trigger an ad hoc run.

Before enabling automatic apply on `main`, make sure:

- The Terraform Cloud workspace exists.
- Its execution mode is `Local`.
- The workspace is not linked to a VCS-driven Terraform Cloud workflow for the same configuration.
- Branch protection and PR review are strict enough for `terraform apply -auto-approve` on `main` to be acceptable.

## Authentication

The GitHub provider in this repository uses `GITHUB_TOKEN` from your shell or GitHub Actions job.

## Source of Truth

[config/repositories.yaml](/home/yadman/Github/AdmanCorp-github-IaC/config/repositories.yaml) defines repository inventory and repo-level settings. [config/rulesets.yaml](/home/yadman/Github/AdmanCorp-github-IaC/config/rulesets.yaml) defines reusable rulesets that repositories reference by key.

Example repository entry:

```yaml
- name: platform-example
  description: Example repository managed by Terraform.
  visibility: public
  license_template: mit
  topics:
    - terraform
    - github
  rulesets:
    - default-branch
```

Supported repository fields include `visibility`, `topics`, `rulesets`, `gitignore_template`, and `license_template`. Set `license_template` to a GitHub license template key such as `mit`, `apache-2.0`, or `gpl-3.0` when you want the repository to be created with a license file.

## Workflow

To add a new managed repository:

1. Add or update reusable rules in `config/rulesets.yaml` if needed.
2. Add the repository definition to `config/repositories.yaml`.
3. Run `terraform fmt -recursive`.
4. Run `terraform init`.
5. Run `terraform validate`.
6. Run `terraform plan` and confirm only the intended GitHub resources change.
7. Merge to `main` to let GitHub Actions apply, or run the workflow manually if you need a controlled execution window.

## Notes

- Ruleset references are validated in the root module so plans fail early if a repository points to an unknown ruleset key.
- The sample YAML files are placeholders and should be replaced with real repository and ruleset definitions before the first apply.
- `.terraform.lock.hcl` should stay committed so GitHub Actions and local runs use the same provider selections.
