## Work

tap "hashicorp/tap", trusted: true
tap "mongodb/brew", trusted: true

brew "eksctl" # Simple command-line tool for creating clusters on Amazon EKS
brew "helm" # Kubernetes package manager
brew "keidarcy/tap/e1s", trusted: true # manage AWS ECS resources, with a focus on Fargate
brew "k9s" # Kubernetes CLI To Manage Your Clusters In Style!
brew "mongodb/brew/mongodb-database-tools" # Standard utilities for interacting with MongoDB.
brew "terraform-docs" # Tool to generate documentation from Terraform modules
brew "tfautomv" # Generate Terraform moved blocks automatically for painless refactoring

cask "mongodb/brew/mongodb-compass" # Interactive tool for analyzing MongoDB dataa
cask "terraform-linters/tap/tflint", trusted: true # Pluggable Terraform linter
