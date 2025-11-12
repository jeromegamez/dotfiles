# CLAUDE.md

Personal chezmoi-managed dotfiles repository for macOS.

## Platform

**macOS only** (darwin). No Windows support - don't suggest Windows-specific solutions or compatibility layers.

## Repository Structure

```
home/                    # Source files (maps to ~/ via .chezmoiroot)
├── private_dot_config/  # ~/.config/ (private files)
├── .chezmoi.toml.tmpl   # Template variables & data
└── .chezmoiscripts/     # Automated setup scripts
```

### Chezmoi Naming Conventions

- `private_*` → restrictive permissions (0600)
- `dot_*` → dotfiles (`.filename`)
- `*.tmpl` → Go templates (processed by chezmoi)
- Combine as needed: `private_dot_ssh/config.tmpl` → `~/.ssh/config`

## Key Details

### Secrets Management
- Uses 1Password CLI for secrets
- Account ID: `UM5PFDCXWRDOXA2MBGNTMSFJ24`
- Template references: `{{ onepasswordRead "op://..." }}`

### Template Data
Defined in `.chezmoi.toml.tmpl`:
- `{{ .email }}` - email address
- `{{ .data.git.name }}` - git username
- `{{ .data.credentials.* }}` - various API tokens
- `{{ .data.versions.* }}` - version pins

### External Resources
Managed in `.chezmoiexternal.toml.tmpl` (auto-refresh every 168h):
- zsh plugins
- neovim config (kickstart.nvim)
- Claude Code plugins/commands

## Common Workflows

### Edit and apply configuration
```bash
chezmoi edit --apply ~/.zshrc
```

### Preview changes
```bash
chezmoi diff
```

### Dry run
```bash
chezmoi apply --dry-run --verbose
```

## Working with Files

When editing files in this repo:
1. Edit in chezmoi source: `chezmoi edit <target-path>`
2. Or edit directly: files are in `home/` with chezmoi naming
3. Apply: `chezmoi apply --verbose`
4. Never commit secrets directly - use 1Password references
