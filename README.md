# Dotfiles

Personal dotfiles managed with [chezmoi](https://github.com/twpayne/chezmoi).

## Installation

```bash
chezmoi init jeromegamez
```

## Requirements

- [1Password CLI](https://developer.1password.com/docs/cli/) for secrets management
- Authenticate before applying configurations:

```bash
eval $(op signin)
```

## Updates

- External deps live in `home/.chezmoiexternal.toml.tmpl`
- Pinned refs keep installs stable
- Check for newer upstream versions:

```bash
./scripts/check-external-updates.sh
```
