# Repository instructions

Personal Apple Silicon macOS dotfiles managed with chezmoi.

## Scope

- Support macOS (`darwin`) only. Do not add Windows or Linux compatibility.
- Treat `home/` as the source of truth; do not edit generated files in `~`.
- Preserve unrelated working-tree changes.
- Keep `IMPROVEMENTS.md` as an uncommitted local working note.
- Commit each completed logical change separately.

## Chezmoi sources

Common filename transformations:

- `dot_*` becomes a dotfile.
- `private_*` receives restrictive permissions.
- `executable_*` becomes executable.
- `*.tmpl` is rendered as a Go template.
- `remove_*` intentionally removes an obsolete target.

Names can be combined. For example,
`private_dot_config/private_git/config.tmpl` renders to
`~/.config/git/config`.

Inspect the current source before relying on configuration details:

- `home/.chezmoi.toml.tmpl` defines machine-local template data.
- `home/.chezmoidata/` contains declarative shared data.
- `home/.chezmoitemplates/homebrew/` defines Homebrew packages.
- `home/.chezmoiscripts/darwin/` contains lifecycle hooks.

Do not duplicate changing template keys or package lists in this file.

## Secrets

- Obtain secret material through 1Password CLI.
- Never commit plaintext credentials, tokens, private keys, or passphrases.
- Use `onepasswordRead` in templates instead of embedding secret values.
- Use `private_` for files that may contain sensitive rendered data.
- Keep secret names generic in documentation and comments.
- Treat rendered diffs and dry-run output as sensitive because templates may
  resolve 1Password values.

## Implementation rules

- Keep lifecycle scripts idempotent.
- Prefer template data over hardcoded machine-specific values.
- Keep cleanup operations narrowly scoped to files created or managed by the
  script. Remove a surrounding directory only when it is known and empty.
- Inspect lifecycle hook filenames before changing execution order; their
  `run_once_*`, `run_onchange_*`, and `run_after_*` prefixes are significant.
- Use a `remove_*` source only when deletion must propagate to every managed
  machine; do not retain one for a completed one-time local cleanup.

## Validation

After changing shell scripts or shell-script templates, run:

```bash
./scripts/lint-shell.sh
```

Validate chezmoi changes against explicit targets whenever possible:

```bash
chezmoi diff ~/.config/zsh/.zshrc
chezmoi apply --dry-run --verbose ~/.config/zsh/.zshrc
```

Also run `git diff --check` before committing. Avoid a full apply when a scoped
preview or apply is sufficient.
