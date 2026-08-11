# Machine profiles

This repository manages a shared development environment across personal and work
machines. Machine profiles should keep the shared configuration useful without
making every machine inherit the same credentials, software, or system policy.

## Safety invariant

Configuration shared by all profiles must be safe and non-destructive on any
managed machine. In particular, shared configuration must not:

- retrieve credentials that belong to another profile;
- import a profile-specific private key;
- assume that an existing unmanaged file can be replaced or removed;
- install software or change system settings unless that behavior is explicitly
  part of the selected profile.

The `personal` and `work` values in the machine-local chezmoi configuration are
mutually exclusive package, machine-policy, and Git-context selectors. Each
computer enables exactly one profile and its matching Git context. Static,
non-secret policy belongs in `.chezmoidata`; prompted, computed, and
secret-backed values belong in the machine-local configuration or the target
template that consumes them.

Each machine also records a 1Password account and a secret reference for its
GitHub API rate-limit PAT. The reference, not the token, is stored in chezmoi's
machine-local configuration. The mise and Composer templates resolve the same
PAT into private configuration files. Persisting this token avoids repeated
1Password authorization prompts and is acceptable because it has no permissions
beyond increasing the public GitHub API rate limit. The reference may point to
different 1Password accounts and items on personal and work machines. This PAT
is not used to authenticate GitHub CLI; `gh auth login` manages that credential
separately.

## Git contexts

Git identity is selected by repository location within the selected profile:

- repositories under `~/Code/personal/` use the personal email, personal SSH
  authentication key, and GPG signing key;
- on a personal-profile machine, the chezmoi source repository stays at its
  standard XDG location under `~/.local/share/chezmoi/` and also uses the
  personal context;
- repositories under `~/Code/work/` use the work email and one work SSH key for
  both authentication and SSH commit signing;
- repositories outside those directories have no global name or email, so
  `user.useConfigOnly` prevents an accidental commit with the wrong identity.

Only the selected profile prompts for an email and public SSH key. These values
are machine-local chezmoi data. The public key file is rendered under
`~/.config/git/keys/`; its corresponding private key stays in the 1Password
SSH agent. Git's conditional includes set an explicit public key with
`IdentitiesOnly=yes`, ensuring that SSH offers the intended agent key when
multiple identities are available. The directories do not need to exist when
chezmoi is applied. Changing the selected profile removes the previously managed
Git fragment and public key file on the next apply.

The work SSH public key must be registered as both an authentication key and a
signing key with the work GitHub account. The personal SSH public key is used
only for authentication; personal commits continue to use GPG signing.
The personal machine profile imports the personal GPG private key automatically.
The work profile neither configures the personal Git context nor imports its
private key.

## Choosing a chezmoi mechanism

Use the narrowest mechanism that expresses the desired difference:

- Use a normal template when a managed file has small profile-specific sections.
- Use shared templates under `.chezmoitemplates/` when multiple targets or
  profiles share substantial contents.
- Use `includeTemplate` or the `template` action when included contents must also
  be rendered with template data.
- Use `include` only for literal contents that must not be rendered as a
  template.
- Use `.chezmoiignore` when a target must be completely unmanaged on a profile.
  Ignore patterns name target paths, not encoded source-state paths.
- Use small target wrappers plus a shared template when identical contents must
  live at different paths on different systems.

Do not use an empty rendered template to preserve an existing target. Chezmoi
removes a target when its rendered contents are empty. Ignore the target instead.

References:

- <https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/>
- <https://www.chezmoi.io/reference/special-directories/chezmoitemplates/>
- <https://www.chezmoi.io/reference/special-files/chezmoiignore/>

## Profile boundaries

### Shared

The shared layer contains portable, non-secret preferences such as the XDG base
directory layout, shell behavior, aliases, editor configuration, and common tool
settings. Shared files may use profile fragments for identity or authentication,
but the shared fragment itself must not contain those values.

### Personal machine profile

The personal profile may enable personal credentials, personal applications,
and opinionated macOS configuration.

### Work machine profile

The work profile may use the same XDG layout and shared development environment,
but must not retrieve, store, import, or expose personal secret credentials.
The work profile configures only its work identity and public SSH key.

## XDG migrations and removal

Root-level files can be removed when they are deliberately replaced by managed
XDG targets and the migration applies to every managed machine. Before removal,
inspect and migrate any useful contents.

The current intended migrations are:

- `~/.gitconfig` to `~/.config/git/config`;
- `~/.zprofile` to `~/.config/zsh/.zprofile`, after `~/.zshenv` sets `ZDOTDIR`;
- `~/.zsh_history` to `~/.local/state/zsh/history`;
- removal of `~/.zsh_sessions` after Apple shell sessions are disabled.

A `remove_` source is not a permanent substitute for an unreviewed migration. It
should remain only when absence of the target is an intentional invariant on all
managed machines.

## Validation

Changes that affect profiles must be rendered and checked with representative
data for both `personal` and `work`. Validation must not retrieve real secrets or
print rendered secret values.

Before applying a new profile, inspect the ignored and managed targets, review a
verbose dry run, and apply explicit targets where practical. A full apply can run
lifecycle scripts, install software, request administrator privileges, and change
macOS settings.
