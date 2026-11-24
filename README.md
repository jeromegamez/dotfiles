# Dotfiles

Personal and work Apple Silicon macOS configuration managed with
[chezmoi](https://www.chezmoi.io/). Secrets are pulled via 1Password CLI and
never stored in this repository.

On macOS, `chezmoi apply` installs software, changes system preferences, may
request administrator privileges, and restarts affected services.

See [MACHINE-PROFILES.md](MACHINE-PROFILES.md) for profile boundaries,
[CONTRIBUTING.md](CONTRIBUTING.md) before changing the repository, and
[export-checklist.md](export-checklist.md) for manual data to migrate between
Macs.

## Bootstrap

Install chezmoi, Homebrew, and 1Password:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install --cask 1password 1password-cli
```

Manual prerequisites before initializing chezmoi:

1. Grant the terminal app **Full Disk Access** (**System Settings > Privacy &
   Security > Full Disk Access**), then reopen it (required for Safari
   preferences).
2. Sign in to the 1Password desktop app and enable Touch ID, the Developer
   experience, the SSH Agent, CLI integration, and **Generate SSH config files
   from 1Password SSH bookmarks**.
3. Verify CLI auth with `op whoami`.

Initialize, review, and apply (rendered previews may contain secrets; do not
share them):

```bash
~/.local/bin/chezmoi --verbose init https://github.com/jeromegamez/dotfiles.git
~/.local/bin/chezmoi --verbose diff
~/.local/bin/chezmoi --verbose apply --dry-run
~/.local/bin/chezmoi --verbose apply
```

Open a new terminal once apply completes.

### Manual post-bootstrap steps

- Exclude `~/Code` from Spotlight (**System Settings > Spotlight > Search
  Privacy**).
- On `personal` machines, if using unattended agent Git signing
  (`AGENT_UNATTENDED=1`), generate the local signing key once, re-apply
  `allowed_signers`, and register the public key on GitHub as a Signing Key:

```bash
ssh-keygen -t ed25519 -N "" -C "agent-unattended@jerome.gamez.name" -f ~/.ssh/id_ed25519_agent
chezmoi --verbose apply ~/.config/git/allowed_signers
```

## Workspace conventions

- Organize repositories by trust profile and forge:
  `~/Code/<personal|work|reference>/<forge>/<owner>/<repository>`.
- To change prompt answers within the same profile, run
  `chezmoi --verbose init --prompt`. Switching profiles requires a fresh
  bootstrap (see [MACHINE-PROFILES.md](MACHINE-PROFILES.md)).

## Maintenance

- Edit managed files through chezmoi: `chezmoi edit --apply <target>`
- Pull and apply updates on another Mac: `chezmoi --verbose update` (or pass
  `--apply=false` to inspect with `diff` and `apply --dry-run` first)
- Run routine tool updates: `maintenance` (Homebrew only: `brew-maintenance`)
- Validate shell and template changes: `./scripts/lint-shell.sh`
