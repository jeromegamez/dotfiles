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

- Packages, including the Zsh plugins, are managed in the generated Brewfile at
  `~/.config/homebrew/Brewfile`.
- Run the managed maintenance command to update Homebrew and its packages:

```bash
brew-maintenance
```

## Bootstrap side effects

- `home/.chezmoiscripts/darwin/run_onchange_set_homebrew_zsh_shell.sh.tmpl` may:
  - touch `/etc/shells`
  - change login shell with `chsh`
  - require `sudo` when adding Homebrew zsh to `/etc/shells`
- Expect prompt during `chezmoi apply` when shell setup needs changes
