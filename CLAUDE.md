# CLAUDE.md

Guidance for Claude Code when working in this chezmoi-managed macOS/Linux dotfiles repo.

## Overview

This is a personal dotfiles repository managed with [chezmoi](https://www.chezmoi.io/), containing configuration files and setup scripts for macOS development environments. The repository uses chezmoi's templating system to manage sensitive data via 1Password CLI and handle platform-specific configurations.

## Guardrails

**Target platforms**: macOS and Linux only
- Primary platform: macOS (darwin)
- Secondary platform: Linux (for server/container environments)
- **Windows is explicitly out of scope and should never be considered**

When making changes:
- Do not add Windows-specific code paths or conditions
- Do not suggest Windows compatibility layers (WSL, Git Bash, etc.)
- Focus solutions on macOS/Linux-compatible approaches
- Scripts should target bash/zsh on Unix-like systems

## Repository Structure

- **`home/`**: Source directory for dotfiles (maps to `~/` due to `.chezmoiroot`)
  - Configuration files use chezmoi naming conventions:
    - `private_*` → files/directories with restrictive permissions
    - `dot_*` → files starting with `.`
    - `*.tmpl` → Go templates processed by chezmoi
- **`Setup/`**: Installation configuration (`Brewfile` lists Homebrew packages, casks, and Mac App Store applications)
- **`.chezmoiscripts/`**: Automated setup scripts
  - `darwin/run_onchange_before_1-install-homebrew-packages.sh.tmpl`: Installs Homebrew packages
  - `darwin/run_onchange_after_*.sh*`: Post-installation configuration scripts
  - `run_once_*.sh`: One-time installation scripts

## Key Configurations

### Templates & Data Sources

- **`.chezmoi.toml.tmpl`**: Defines template variables (email, hostname, Homebrew prefix)
- **`.chezmoiexternal.toml.tmpl`**: Manages external resources:
  - zsh plugins (autosuggestions, syntax-highlighting)
  - Neovim config from kickstart.nvim
  - Google Cloud SDK
  - Claude Code commands and agents from community repositories

### Managed Applications

- **Development Tools**: neovim, tmux, zsh, git, gh, glab, jq, ripgrep
- **Version Managers**: asdf, tenv (Terraform/OpenTofu), nvm (via script)
- **Cloud Tools**: awscli, gcloud SDK, granted (AWS access)
- **PHP**: PHP 8.4 with extensions (amqp, apcu, grpc, mongodb, redis, xdebug)
- **Infrastructure**: tenv, terraform-docs, tflint, packer
- **Terminals**: ghostty, starship prompt
- **Other**: 1Password CLI (for secrets), atuin (shell history)

### Configuration Files

- **Shell**: `~/.config/zsh/` (zshrc, zprofile, aliases, git-aliases, lazy-tools)
- **Editor**: neovim config sourced from external kickstart.nvim repo
- **Starship**: Custom prompt configuration in `~/.config/starship/`
- **Git**: Configuration in `~/.config/git/`
- **Claude Code**: Commands and agents in `~/.config/claude/` (auto-synced from community repos; `~/.claude` is a symlink for compatibility)

## Common Workflows

### Making Configuration Changes

```bash
# Edit files in chezmoi source directory
chezmoi edit ~/.zshrc

# See what changes will be applied
chezmoi diff

# Apply changes to home directory
chezmoi apply --verbose

# Or edit and apply in one step
chezmoi edit --apply ~/.zshrc
```

### Managing Secrets

- Secrets are managed via 1Password CLI
- Must authenticate before applying configurations:
  ```bash
  eval $(op signin)
  ```
- Template files use 1Password references (account ID: `UM5PFDCXWRDOXA2MBGNTMSFJ24`)

### Testing Changes

```bash
# Dry run to see what would change
chezmoi apply --dry-run --verbose

# View source state without applying
chezmoi source path
```

### Updating External Dependencies

External resources (zsh plugins, nvim config, Claude commands) auto-refresh every 168 hours. To force update:

```bash
chezmoi update
```

### Adding New Packages

1. Edit `Setup/Brewfile`
2. Apply changes with `chezmoi apply --verbose` (triggers `brew bundle --file=Setup/Brewfile`)

## Naming Conventions

When working with chezmoi files:

- Use `private_` prefix for sensitive/private files (sets 0600 permissions)
- Use `dot_` prefix for dotfiles (e.g., `dot_zshrc` → `.zshrc`)
- Use `.tmpl` suffix for files requiring template processing
- Combine prefixes as needed: `private_dot_ssh/config.tmpl` → `~/.ssh/config`

## Important Notes

- This repository is macOS-focused (darwin-specific scripts and configurations)
- The `.chezmoiroot` file sets `home/` as the root for target directory
- Template variables are defined in `.chezmoi.toml.tmpl`
- Scripts in `.chezmoiscripts/` run automatically based on chezmoi lifecycle hooks
- Never commit 1Password credentials or sensitive data directly
- Follow `.editorconfig` settings (4 spaces, LF line endings, UTF-8)
