## Plan: GitHub Org IaC Bootstrap

Bootstrap this repository as a Terraform-based, data-driven GitHub organization management repo. Phase 1 should manage organization settings, repositories, and repository rulesets for newly managed resources only, using Terraform Cloud as the remote state backend. The recommended approach is to keep provider and environment wiring simple, keep the source of truth in versioned data files, and wrap repeatable GitHub resources in small modules so repo onboarding and ruleset reuse stay predictable.

**Steps**
1. Phase 1: Repository bootstrap. Add the Terraform root layout with provider version pinning, Terraform version constraints, Terraform Cloud backend configuration placeholders, shared variables, and a minimal directory structure for reusable modules and environment data. This blocks all later steps.
2. Phase 1: Documentation bootstrap. Replace the placeholder README with operational documentation covering purpose, scope, prerequisites, Terraform Cloud workspace expectations, GitHub authentication via environment variables or workspace variables, and the workflow for adding a new managed repository. This can run in parallel with step 3 once the final structure is decided.
3. Phase 2: Data model design. Define a versioned data-driven source of truth for repositories and rulesets, such as YAML or JSON files under a dedicated config directory, with a schema that captures repository metadata, visibility, features, branch defaults, archival policy, and ruleset attachment choices. This depends on step 1.
4. Phase 2: Module design. Create focused Terraform modules for repository creation/configuration and reusable ruleset application. Keep organization-level settings in the root or a dedicated org module depending on complexity. Module inputs should map directly from the data model and avoid over-generalizing beyond current scope. This depends on step 3.
5. Phase 3: Root composition. In the root module, decode the source-of-truth files, normalize defaults in locals, instantiate repository resources from the data set, apply repository rulesets selectively, and manage chosen organization settings. This depends on steps 3 and 4.
6. Phase 3: Validation guardrails. Add variable validation, sensible defaults, and example data so plans fail early on invalid repository definitions. Include formatting and validation commands in the documented workflow. This depends on step 5.
7. Phase 4: Terraform Cloud integration. Document or add the expected workspace variables, execution mode assumptions, and plan/apply workflow. If CI is desired later, leave a clear extension point for GitHub Actions or Terraform Cloud VCS-driven runs, but keep it out of phase 1 implementation unless explicitly requested. This depends on step 5.
8. Phase 4: Verification. Validate syntax and provider wiring with terraform fmt, terraform validate, and a dry-run plan against non-production inputs or an isolated workspace. Manually verify that creating a sample repository and attaching its ruleset produces the intended GitHub settings. This depends on steps 5 through 7.

**Relevant files**
- `/home/yadman/Github/AdmanCorp-github-IaC/README.md` — Replace placeholder content with usage, workflow, Terraform Cloud, and authentication guidance.
- `/home/yadman/Github/AdmanCorp-github-IaC/.gitignore` — Reuse existing Terraform ignore patterns; only extend if the final layout introduces additional generated artifacts.
- `/home/yadman/Github/AdmanCorp-github-IaC/main.tf` — Root composition for provider, locals, and module instantiation.
- `/home/yadman/Github/AdmanCorp-github-IaC/versions.tf` — Terraform and provider version constraints plus backend block skeleton.
- `/home/yadman/Github/AdmanCorp-github-IaC/variables.tf` — Shared variables for org name, defaults, and feature flags.
- `/home/yadman/Github/AdmanCorp-github-IaC/locals.tf` — Data decoding and normalization from config files.
- `/home/yadman/Github/AdmanCorp-github-IaC/outputs.tf` — Optional outputs for managed repositories or derived identifiers if useful.
- `/home/yadman/Github/AdmanCorp-github-IaC/config/repositories.yaml` — Versioned repository inventory and desired settings.
- `/home/yadman/Github/AdmanCorp-github-IaC/config/rulesets.yaml` — Versioned reusable ruleset definitions and attachment mapping.
- `/home/yadman/Github/AdmanCorp-github-IaC/modules/repository/*` — Encapsulate repository resource creation and configuration.
- `/home/yadman/Github/AdmanCorp-github-IaC/modules/ruleset/*` — Encapsulate repository ruleset resources and inputs.

**Verification**
1. Run `terraform fmt -check -recursive` from the repo root.
2. Run `terraform init` against the Terraform Cloud backend configuration in a non-production workspace.
3. Run `terraform validate` after wiring provider variables.
4. Run `terraform plan` with sample repository and ruleset data to confirm only expected GitHub resources are proposed.
5. Manually inspect the created test repository in GitHub to verify visibility, settings, and attached ruleset behavior.
6. Confirm the documented workflow in the README is sufficient for adding a second repository without changing module code.

**Decisions**
- Use Terraform as the IaC tool.
- Use Terraform Cloud/Enterprise for remote state.
- Phase 1 scope includes organization settings, repositories, and repository rulesets.
- Use a data-driven source of truth rather than one resource block per repository.
- Manage only new resources in phase 1; importing existing GitHub resources is deliberately excluded.
- Excluded for now: teams and memberships, org or repo secrets, Actions variables, webhooks, GitHub Apps, and CI automation beyond documenting the path forward.

**Further Considerations**
1. Prefer YAML for the source-of-truth files if human editing and review readability matter most; prefer JSON only if you expect heavy automated generation.
2. Keep rulesets reusable and reference them by key from repository definitions instead of duplicating rule blocks per repository.
3. If organization settings expand materially, split them into a dedicated module later; for the initial setup, root-level management is simpler and easier to audit.
