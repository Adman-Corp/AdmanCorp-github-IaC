terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.11"
    }
  }

  cloud {
    organization = "AdmanCorp"

    workspaces {
      name = "admancorp-github-iac"
    }
  }
}



