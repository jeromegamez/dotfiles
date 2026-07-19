tap "hashicorp/tap", trusted: true
tap "keidarcy/tap", trusted: true
tap "mongodb/brew", trusted: true

brew "cosign" # Container Signing (needed for tenv)
brew "hashicorp/tap/packer" # https://www.packer.io/
brew "keidarcy/tap/e1s" # manage AWS ECS resources, with a focus on Fargate
brew "mongodb/brew/mongodb-database-tools" # Standard utilities for interacting with MongoDB.
brew "tenv" # OpenTofu / Terraform / Terragrunt / Atmos version manager

cask "mongodb/brew/mongodb-compass" # Interactive tool for analyzing MongoDB dataa
