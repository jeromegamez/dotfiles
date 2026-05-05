# Dotfiles repo guide

Personal chezmoi-managed dotfiles repo for macOS.

## Platform

- macOS only (darwin)
- Do not suggest Windows-specific fixes or compatibility layers

## Source tree

- Source files live under `home/`

### ChezMoi naming rules

- `private_*` → restrictive permissions
- `dot_*` → dotfiles (`.filename`)
- `*.tmpl` → Go templates rendered by chezmoi
- Combine as needed, e.g. `private_dot_ssh/config.tmpl` → `~/.ssh/config`

## Secrets and credentials

- Use 1Password CLI for secret material
- Never commit plaintext secrets, API keys, or credentials
- Prefer `onepasswordRead` refs in templates instead of embedding values
- Keep secret names generic in docs and comments

## Project conventions

- Edit source files under `home/`, not generated files in `~`
- Keep scripts idempotent
- Prefer template data over hardcoded machine-specific values
- Use `private_` for anything that may contain secrets or tokens
- `remove_*` markers intentionally delete obsolete targets

## Template data

`home/.chezmoi.toml.tmpl` = source of truth for template data.
Do not mirror keys here; inspect file for current keys and values.

## External resources

`home/.chezmoiexternal.toml.tmpl` = source of truth for external resources.
Do not mirror entries here; inspect file for current entries.

## Scripts

`.chezmoiscripts/` contains lifecycle hooks.
Inspect filenames for current `run_once_*`, `run_onchange_*`, and `run_after_*` hooks.

macOS-specific scripts live under `darwin/`.

## Example workflows

```bash
chezmoi edit --apply ~/.zshrc
chezmoi diff
chezmoi apply --dry-run --verbose
```