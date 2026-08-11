# Repository instructions

Personal Apple Silicon macOS dotfiles managed with chezmoi.

## Scope

- Support macOS (`darwin`) only. Do not add Windows or Linux compatibility.
- Treat `home/` as the source of truth; do not edit generated files in `~`.
- Review and diagnosis tasks do not authorize edits or commits.
- For implementation tasks, preserve unrelated changes and create one local commit per completed logical change unless the user asks otherwise.
- Never stage unrelated changes or push without an explicit request.

## Chezmoi sources

- Chezmoi filename attributes control target names, permissions, template rendering, and removal. Inspect the complete source name before changing it.
- Inspect current sources instead of recording changing keys or package lists here.
- `home/.chezmoi.toml.tmpl` defines machine-local configuration data.
- `home/.chezmoidata/` contains shared, static, non-secret template data.
- `home/.chezmoitemplates/homebrew/` defines Homebrew packages.
- `home/.chezmoiscripts/darwin/` contains lifecycle hooks.

## Secrets

- Retrieve secret material through 1Password CLI using chezmoi's secret-manager template integration; never embed secret values in source files.
- Never commit plaintext credentials, tokens, private keys, or passphrases.
- A `private_` source attribute restricts target permissions; it does not encrypt repository content.
- Treat rendered diffs and dry-run output as sensitive because templates may resolve secrets.

## Implementation rules

- Keep lifecycle scripts idempotent.
- Prefer template data over hardcoded machine-specific values.
- Limit cleanup to files created or managed by the script. Remove a surrounding directory
  only when it is known and empty.
- Treat the complete lifecycle hook filename as significant, including combined `run_once`
  or `run_onchange` and `before` or `after` attributes.
- Use a `remove_` source only when deletion must propagate to every managed machine; do not
  retain one after a completed one-time local cleanup.

## Validation

- Always pass `--verbose` when invoking chezmoi.
- Do not run an unscoped `chezmoi apply` unless explicitly requested; it can install
  software, request privileges, change system settings, and restart services.
- Validate each touched destination with explicit targets when possible:

  ```bash
  chezmoi --verbose diff <target>
  chezmoi --verbose apply --dry-run <target>
  ```

- After changing shell scripts or shell-script templates, run `./scripts/lint-shell.sh`.
- After changing Homebrew templates, render the affected Brewfile and validate it with
  Homebrew.
- Run `git diff --check` before committing.
