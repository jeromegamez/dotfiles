tap "hashicorp/tap", trusted: true
tap "keidarcy/tap", trusted: true
tap "mongodb/brew", trusted: true

brew "hashicorp/tap/packer" # https://www.packer.io/
brew "keidarcy/tap/e1s" # manage AWS ECS resources, with a focus on Fargate
brew "mongodb/brew/mongodb-database-tools" # Standard utilities for interacting with MongoDB.

cask "mongodb/brew/mongodb-compass" # Interactive tool for analyzing MongoDB dataa
