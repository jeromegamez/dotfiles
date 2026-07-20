# Dotfiles

Personal macOS dotfiles managed with
[chezmoi](https://github.com/twpayne/chezmoi).

## Scope

- macOS only; the current configuration assumes Apple Silicon and Homebrew at
  `/opt/homebrew`.
- Secrets, signing material, and generated SSH configuration come from
  1Password. They are not stored in this repository.
- A full apply bootstraps software and changes system settings; it is not only a
  dotfile copy operation.

## Prerequisites

Install and configure these before initializing the repository:

- [Homebrew](https://brew.sh/)
- [chezmoi](https://www.chezmoi.io/install/)
- The 1Password desktop app and
  [1Password CLI](https://developer.1password.com/docs/cli/)
- Access to the configured 1Password account and its required items

With Homebrew available, the command-line prerequisites can be installed with:

```bash
brew install chezmoi
brew install --cask 1password 1password-cli
```

Enable 1Password CLI integration in the desktop app, then authenticate before
running `chezmoi init`; the configuration template reads secret-backed values
during initialization.

```bash
op signin
```

## Machine profiles

`home/.chezmoi.toml.tmpl` prompts for either the `work` or `personal` profile
during initialization. The selected profile controls identity, secrets, and
parts of the generated Brewfile.

The choice is stored in the generated chezmoi configuration and reused by
subsequent initialization. To select a different profile, force the prompt and
then review the resulting target state before applying:

```bash
chezmoi init --prompt
```

Verify the selected profile without printing secret values:

```bash
chezmoi execute-template '{{ printf "work=%t personal=%t\n" .work .personal }}'
```

## Bootstrap

Initialize the source repository without applying it immediately:

```bash
chezmoi init jeromegamez
```

Inspect narrowly scoped targets first:

```bash
chezmoi diff ~/.config/zsh/.zshrc ~/.config/homebrew/Brewfile
chezmoi apply --dry-run --verbose ~/.config/zsh/.zshrc ~/.config/homebrew/Brewfile
```

Diff and dry-run output can contain values rendered from 1Password-backed
templates. Treat the output as secret material and avoid saving or sharing
broad previews.

When the profile and source are correct, run the full bootstrap from an
interactive terminal:

```bash
chezmoi apply
```

Keep the terminal available for confirmation, administrator, and login-shell
prompts. Open a new terminal session after the apply completes.

## Bootstrap effects

A full apply can:

- Install Rosetta on Apple Silicon.
- Generate the managed Brewfile at `~/.config/homebrew/Brewfile`, then install
  and upgrade its formulae, casks, and applications.
- Install uv; install or update mise, Node LTS, Google Cloud CLI, AWS Session
  Manager Plugin, Composer, and global Composer packages.
- Retrieve the GPG private key and passphrase from 1Password and import the key
  into GnuPG.
- Generate SSH host configuration from SSH items in 1Password.
- Add Homebrew Zsh to `/etc/shells` and change the login shell after
  confirmation.
- Apply macOS defaults for the keyboard, trackpad, Finder, Dock, Safari,
  screenshots, power management, timezone, login window, and related settings.
- Enable the macOS application firewall and stealth mode.

Commands that install system packages, update `/etc/shells`, change NVRAM,
configure power management, or modify system-wide preferences can request
administrator privileges. Some applications and macOS services are restarted
after their preferences change.

## Maintenance

Edit source files under `home/`, not their generated copies in the home
directory. A focused edit/apply workflow is:

```bash
chezmoi edit --apply ~/.config/zsh/.zshrc
```

Homebrew packages are assembled from the templates under
`home/.chezmoitemplates/homebrew/` into
`~/.config/homebrew/Brewfile`. Run the managed maintenance command to update
Homebrew and its packages, remove unused dependencies, and clean old artifacts:

```bash
brew-maintenance
```

The maintenance command can request administrator privileges if it encounters
incorrect ownership in Homebrew-managed directories.

## Manual migration

Some applications require manual export and import steps. See the
[application export checklist](export-checklist.md) when setting up or replacing
a Mac.
