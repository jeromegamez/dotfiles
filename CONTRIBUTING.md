# Contributing

Read the [README](README.md) for the architecture, bootstrap process, repository
layout, and maintenance workflows.

## Scope

- Support macOS (`darwin`) and Linux. Do not add Windows compatibility.
- Treat `home/` as the source of truth. Do not edit generated files in the home
  directory.
- Keep changes focused and preserve unrelated worktree changes.

## Chezmoi sources

- Inspect the complete source filename before changing it. Chezmoi filename
  attributes control target names, permissions, template rendering, and
  removal.
- Inspect current sources instead of recording changing keys or package lists
  in documentation.

## Secrets

- Retrieve secret material through 1Password CLI using chezmoi's secret-manager
  template integration. Never embed secret values in source files.
- Never commit plaintext credentials, tokens, private keys, or passphrases.
- A `private_` source attribute restricts target permissions; it does not
  encrypt repository content.
- Treat rendered diffs and dry-run output as sensitive because templates may
  resolve secrets.

## Implementation

- Keep lifecycle scripts idempotent.
- Prefer template data over hardcoded machine-specific values.
- Limit cleanup to files created or managed by the script. Remove a surrounding
  directory only when it is known and empty.
- Treat the complete lifecycle hook filename as significant, including combined
  `run_once` or `run_onchange` and `before` or `after` attributes.
- Use a `remove_` source only when deletion must propagate to every managed
  machine. Do not retain one after a completed one-time local cleanup.

## Validation

Always pass `--verbose` when invoking chezmoi. Do not run an unscoped
`chezmoi apply` while validating a change: it can install software, request
privileges, change system settings, and restart services.

Validate each touched destination with explicit targets when possible:

```bash
chezmoi --verbose diff <target>
chezmoi --verbose apply --dry-run <target>
```

- After changing shell scripts or shell-script templates, run
  `./scripts/lint-shell.sh`.
- After changing Homebrew templates, render the affected Brewfile and validate
  it with Homebrew.
- Run `git diff --check` before committing.

Keep each commit focused on one logical change and exclude unrelated worktree
changes.
