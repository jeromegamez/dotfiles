# Dotfiles

Personal macOS development environment managed with
[chezmoi](https://www.chezmoi.io/). The repository defines shell configuration,
developer tools, applications, language runtimes, credentials-backed files, and
selected macOS preferences.

The setup targets Apple Silicon Macs and assumes Homebrew is installed at
`/opt/homebrew`.

## How it works

- **chezmoi** renders the source files under `home/` into their locations in the
  home directory.
- **Homebrew** installs command-line tools, applications, fonts, and Mac App
  Store applications from a generated Brewfile.
- **mise** provides the Node.js and Python versions used from the shell.
- **uv** manages Python projects while using mise-provided Python runtimes.
- **1Password CLI** supplies secret values, the GPG key, and generated SSH host
  configuration. Secrets are not stored in this repository.
- **Lifecycle scripts** install supporting tools, configure the login shell,
  and apply selected macOS defaults and security settings.

A full `chezmoi apply` can install software, request administrator privileges,
change system preferences, and restart affected macOS services. It is more than
a file-copy operation.

## Machine configuration

During initialization, [`home/.chezmoi.toml.tmpl`](home/.chezmoi.toml.tmpl)
prompts once for:

- a `personal` or `work` package profile;
- the Git commit email for that machine.

The answers are stored in chezmoi's machine-local configuration, not in the
repository. Prompt for them again with:

```bash
chezmoi init --prompt
```

See [`MACHINE-PROFILES.md`](MACHINE-PROFILES.md) for the profile boundaries,
credential rules, XDG migration policy, and the chezmoi mechanisms used to keep
machine-specific behavior centralized.

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

## Bootstrap

Install the prerequisites:

```bash
brew install chezmoi
brew install --cask 1password 1password-cli
```

Enable the 1Password desktop application's CLI integration and authenticate:

```bash
op signin
```

Initialize the repository without applying it immediately:

```bash
chezmoi init jeromegamez
```

Review the changes before applying them:

```bash
chezmoi diff
chezmoi apply --dry-run --verbose
```

Rendered previews can contain values obtained from 1Password. Treat their
output as sensitive and do not save or share it indiscriminately.

Apply the complete configuration from an interactive terminal:

```bash
chezmoi apply
```

Some hooks may request confirmation, administrator access, or a login-shell
change. Open a new terminal after the bootstrap completes.

## Tool ownership

Homebrew owns applications, including the ChatGPT desktop app, and general
command-line tools. mise owns the Codex CLI as well as the Node.js and Python
runtimes selected by the shell. Homebrew may retain its own Node.js and Python
copies as dependencies of other formulae.

The default mise runtimes are declared in
[`home/private_dot_config/private_mise/config.toml`](home/private_dot_config/private_mise/config.toml).
Pi is installed under `~/.local/share/pi` and its launcher always executes it
with Node.js 25. Reproducible Pi packages are listed in
[`home/.chezmoidata/pi.yaml`](home/.chezmoidata/pi.yaml); Pi's mutable settings
remain unmanaged.

## Maintenance

Edit source files through chezmoi rather than changing generated targets
directly:

```bash
chezmoi edit --apply ~/.config/zsh/.zshrc
```

Useful maintenance commands:

```bash
brew-maintenance       # update Homebrew and installed packages
mise upgrade           # update mise-managed runtimes
pi update --all        # update Pi and its packages using Node.js 25
./scripts/lint-shell.sh
```

Install a Pi package for local evaluation with `pi install npm:package-name`.
Add it to `home/.chezmoidata/pi.yaml` when it should be installed on every
managed Mac.

Use [`export-checklist.md`](export-checklist.md) for application data that
cannot be reproduced automatically.
