# Dotfiles

Personal and work machine configuration managed with
[chezmoi](https://www.chezmoi.io/). The repository defines shell configuration,
developer tools, language runtimes, credentials-backed files, applications, and
selected system preferences.

This configuration targets Apple Silicon macOS. Automated package and
application installation and system configuration use Homebrew at
`/opt/homebrew`.

See [CONTRIBUTING.md](CONTRIBUTING.md) before changing the repository.

## How it works

- **chezmoi** renders the source files under `home/` into their locations in the
  home directory.
- **Homebrew** installs macOS command-line tools, applications, fonts, and Mac
  App Store applications from a generated Brewfile.
- **mise** provides the Node.js and Python versions used from the shell.
- **uv** manages Python projects while using mise-provided Python runtimes.
- **1Password CLI** supplies profile-specific secret values and generated SSH
  host configuration. On personal machines it also supplies the personal GPG
  key. Private SSH keys remain in the 1Password SSH agent. Secrets are not
  stored in this repository.
- **macOS lifecycle scripts** install supporting tools, configure the login
  shell, and apply selected defaults and security settings.

On macOS, a full `chezmoi apply` can install software, request administrator
privileges, change system preferences, and restart affected services. It is
more than a file-copy operation.

## Bootstrap

Install the chezmoi binary in `~/.local/bin` with the official installer:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
```

On Apple Silicon macOS, install [Homebrew](https://brew.sh/) and make it
available in the current terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install --cask 1password 1password-cli
```

The dotfiles add `~/.local/bin` to `PATH`, but they have not been applied yet.
Use the binary's full path during the bootstrap.

Before initializing chezmoi, sign in to the 1Password desktop app and configure
it:

1. Enable Touch ID under Settings > Security for CLI integration.
2. Turn on the 1Password Developer experience.
3. Enable the 1Password SSH Agent.
4. Enable CLI integration with the desktop app.
5. Under the SSH Agent's advanced settings, enable **Generate SSH config files
   from 1Password SSH bookmarks**.
6. Ensure the active profile's SSH keys are available to the agent. Add
   `ssh://user@host` URLs to keys that should be associated with specific SSH
   hosts.

The SSH-config setting creates `~/.ssh/1Password/config` and the public-key
files referenced by this repository's generated SSH host configuration. Private
keys remain in 1Password. If a setting is marked as managed, ask the work
administrator whether it can be enabled. See [1Password's SSH Bookmarks
documentation](https://developer.1password.com/docs/ssh/bookmarks/) for the
current interface and behavior.

Authenticate the CLI from an interactive terminal:

```bash
op signin
```

Initialize the repository without applying it immediately. See
[Machine configuration](#machine-configuration) for the prompts:

```bash
~/.local/bin/chezmoi --verbose init \
  https://github.com/jeromegamez/dotfiles.git
```

Review the changes before applying them:

```bash
~/.local/bin/chezmoi --verbose diff
~/.local/bin/chezmoi --verbose apply --dry-run
```

Rendered previews can contain values obtained from 1Password. Treat their
output as sensitive and do not save or share it indiscriminately.

Apply the complete configuration from an interactive terminal:

```bash
~/.local/bin/chezmoi --verbose apply
```

On macOS, some hooks may request confirmation, administrator access, or a
login-shell change. Open a new terminal after the bootstrap completes.

Before installing applications, a hook checks whether Rosetta 2 can run Intel
executables and installs it if needed. Installation requires internet access,
accepts Apple's license automatically, and may request your administrator password.

### Exclude source code from Spotlight

After `~/Code` exists, exclude it once on each Mac through **System Settings ->
Spotlight -> Search Privacy**. Click the add button and select `~/Code`.
See [Apple's Spotlight Search Privacy
instructions](https://support.apple.com/guide/mac-help/mchl1bb43b84/mac).

## Machine configuration

During initialization, [`home/.chezmoi.toml.tmpl`](home/.chezmoi.toml.tmpl)
prompts once for:

- a `personal` or `work` machine profile;
- the active profile's email address;
- on work, the public key used for SSH commit and tag signing;
- a 1Password account and the reference to one low-privilege GitHub API PAT for
  public-data readers and rate-limit elevation.

The answers are stored in chezmoi's machine-local configuration, not in the
repository. To change answers while keeping the same profile, run:

```bash
chezmoi --verbose init --prompt
```

Switching profiles requires a fresh bootstrap. See
[`MACHINE-PROFILES.md`](MACHINE-PROFILES.md) for the steps and credential
boundaries.

The selected profile supplies the default Git identity and signing method
globally: personal uses GPG and work uses an SSH key held by 1Password. SSH
authentication is selected separately by SSH host configuration and 1Password
Bookmarks. Repositories under `~/Code/reference/`, the opposite profile's
`~/Code/` tree, and the chezmoi source on work receive an empty identity guard.

Organize repositories by trust profile and then forge, for example
`~/Code/personal/github.com/owner/repository`,
`~/Code/work/gitlab.com/group/repository`, and
`~/Code/reference/codeberg.org/owner/repository`. Forge directories organize
repositories; they do not select identity or credentials.

## Repository layout

| Path | Purpose |
| --- | --- |
| `home/` | Source state rendered into the home directory |
| `home/.chezmoiscripts/darwin/` | macOS bootstrap and configuration hooks |
| `home/.chezmoitemplates/homebrew/` | Common and profile-specific Homebrew packages |
| `home/.chezmoidata/` | Declarative data such as required Pi packages |
| `scripts/lint-shell.sh` | ShellCheck and shfmt validation for scripts and rendered templates |
| `export-checklist.md` | Manual application data to migrate between Macs |

chezmoi filename conventions describe the target and its permissions. For
example, `private_dot_config/private_git/config.tmpl` renders as
`~/.config/git/config`, with private permissions and template expansion.

## Tool ownership

The standalone installers own chezmoi and the Codex CLI. Homebrew owns
applications, including the ChatGPT desktop app, and general command-line tools.
mise owns the Node.js and Python runtimes selected by the shell. Homebrew may
retain its own Node.js and Python copies as dependencies of other formulae.

The macOS lifecycle installs Codex CLI when it is missing. Update it with
`codex update`.

The default mise runtimes are declared in
[`home/private_dot_config/private_mise/config.toml.tmpl`](home/private_dot_config/private_mise/config.toml.tmpl).
Pi is installed under `~/.local/share/pi` and launched with mise-managed
Node.js. Required packages are listed in
[`home/.chezmoidata/agent-addons.yaml`](home/.chezmoidata/agent-addons.yaml).
Chezmoi installs missing components without upgrading existing ones. Other Pi
settings remain unmanaged.

## Maintenance

Edit source files through chezmoi rather than changing generated targets
directly:

```bash
chezmoi edit --apply ~/.config/zsh/.zshrc
```

Pull and apply the latest committed source state on another machine:

```bash
chezmoi --verbose update
```

To review an update before applying it, pull the source state first and then
inspect the resulting changes:

```bash
chezmoi --verbose update --apply=false
chezmoi --verbose diff
chezmoi --verbose apply --dry-run
chezmoi --verbose apply
```

Useful maintenance commands:

```bash
brew-maintenance         # update Homebrew and installed packages
mise upgrade             # update mise-managed runtimes
codex update             # update Codex CLI
gcloud components update # update Google Cloud CLI and its components
pi update --all          # update Pi and its packages
./scripts/lint-shell.sh
```

Install a Pi package for local evaluation with `pi install npm:package-name`.
Add it to `home/.chezmoidata/agent-addons.yaml` when it should be installed on
every managed Mac.

Use [`export-checklist.md`](export-checklist.md) for application data that
cannot be reproduced automatically.
