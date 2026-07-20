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
subsequent initialization. The Git commit email is also prompted once and kept
in the machine-local configuration instead of this repository. To select a
different profile or email, force the prompts and then review the resulting
target state before applying:

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
- Install uv and mise through Homebrew; install Node LTS, Node 25, and Python
  3.14 through mise; install Pi with Node 25; install or update Google Cloud
  CLI, AWS Session Manager Plugin, Composer, and global Composer packages.
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

## Runtime ownership

Homebrew owns system tools and may retain Node and Python as dependencies of
its formulae. Their generic command links are unlinked after Homebrew bootstrap
and maintenance, while formulae can continue using versioned paths under
`/opt/homebrew/opt`.

mise owns the language runtimes used from the shell:

- Node LTS is the default interactive Node version.
- Node 25 is installed specifically for Pi.
- Python 3.14 is the default Python version.
- mise shims are added early enough for login and non-interactive Zsh shells,
  preventing accidental fallback to Homebrew's Node or Python commands.

uv remains a Homebrew-managed standalone application. Its user configuration
only permits externally managed Python interpreters, so Python comes from mise
instead of uv downloading a second runtime collection.

Pi is installed under `~/.local/share/pi` using npm from mise-managed Node 25.
The managed `~/.local/bin/pi` launcher pins every invocation to Node 25,
including self-updates and package updates, regardless of project-local mise
configuration. Pi's mutable `~/.pi/agent/settings.json` is not managed as a
complete chezmoi file; the installation hook only merges its stable npm command
and ensures the packages listed in `home/.chezmoidata/pi.yaml` are present.

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

Update mise-managed runtimes with:

```bash
mise upgrade
```

Update Pi itself, its packages, or both with:

```bash
pi update
pi update --extensions
pi update --all
```

All three commands run with Node 25 through the managed launcher. uv is updated
with the rest of Homebrew by `brew-maintenance`.

Install a Pi package locally while evaluating it with:

```bash
pi install npm:package-name
```

The mutable Pi settings retain local packages across chezmoi applies. To make a
package reproducible on every machine, add its source to
`home/.chezmoidata/pi.yaml` and run `chezmoi apply`; changing the manifest
causes the Pi installation hook to run again automatically.

Lint plain and rendered template shell scripts with:

```bash
./scripts/lint-shell.sh
```

The command uses synthetic template data and does not access 1Password or the
machine-local chezmoi configuration.

## Manual migration

Some applications require manual export and import steps. See the
[application export checklist](export-checklist.md) when setting up or replacing
a Mac.
