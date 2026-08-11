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
mutually exclusive package, machine-policy, Git-identity, and signing selectors.
Each computer enables exactly one profile. Static, non-secret policy belongs in
`.chezmoidata`; prompted, computed, and secret-backed values belong in the
machine-local configuration or the target template that consumes them.

Each machine also records a 1Password account and a secret reference for its
GitHub API rate-limit PAT. The reference, not the token, is stored in chezmoi's
machine-local configuration. The mise and Composer templates resolve the same
PAT into their own private configuration files. Persisting this token avoids
repeated 1Password authorization prompts. It should have only the permissions
needed for low-risk public GitHub API reads and rate-limit elevation; fine-grained
tokens are still limited by their endpoint permissions. The reference may point
to different 1Password accounts and items on personal and work machines. This
PAT is not used by Git, SSH, commit signing, or GitHub CLI; `gh auth login`
manages its credential separately.

## Git identity and signing

The selected machine profile provides one default Git name, email, and signing
method globally:

- personal commits and annotated tags use the static personal GPG fingerprint;
- work commits and annotated tags use the prompted work SSH signing public key;
- `user.useConfigOnly` prevents Git from guessing a missing identity.

The work public key is rendered at
`~/.config/git/keys/work-signing.pub`; its private key remains in the work
1Password account. It may also be used for SSH authentication by associating it
with the appropriate 1Password Bookmarks. Each forge may require the same public
key to be registered separately for authentication and signing. Whether
1Password's vault and authorization model satisfies an organization's
passphrase policy is a policy decision - it is not something GitHub can infer
from the uploaded public key.

The static `~/.config/git/no-identity` fragment clears the default identity and
sets `push.default = nothing` for:

- `~/Code/reference/` on every profile;
- `~/Code/work/` on personal;
- `~/Code/personal/` on work;
- `~/.local/share/chezmoi/` on work.

These conditional includes are workflow guardrails, not security boundaries.
Repository-local configuration and environment variables can override them,
moving a repository changes which rule matches, and an explicit push can bypass
`push.default = nothing`. Forge-side credentials, SSO, and repository
permissions are the actual access controls. The chezmoi source therefore remains
at its standard XDG path and is pull/apply-oriented on work, but server-side
read-only access is required for genuine push prevention.

## Repository organization

Group repositories by trust profile first and forge second:

```text
~/Code/personal/github.com/owner/repository
~/Code/personal/gitlab.com/owner/repository
~/Code/work/github.com/owner/repository
~/Code/work/git.company.example/group/repository
~/Code/reference/codeberg.org/owner/repository
```

Use the actual hostname for self-hosted services. Forge directories are only
organizational and do not select identity, signing, or authentication. Prefer
HTTPS for public reference clones. Put a contribution fork under the active
profile and add the public upstream as another remote.

## SSH authentication

Git does not select SSH keys by repository path. SSH uses the 1Password agent
and the generated files under `~/.ssh/1Password/`. 1Password's Bookmarks config
maps host-and-user pairs to keys. The chezmoi-generated companion file remains
necessary because it also supplies default users and alias-to-host mappings,
including custom hostnames and ports.

macOS uses 1Password's application socket and signing program. Linux uses
`~/.1password/agent.sock`; Git's default `ssh-keygen` signer uses that socket.
Linux therefore requires the native 1Password installation, an enabled SSH
agent, Git 2.34 or newer, and compatible OpenSSH signing support. Validate SSH
authentication and a signed disposable commit on each Linux machine before
relying on it.

## Personal-only GPG

The personal profile installs GnuPG, pinentry-mac, and GPG Suite, exports
`GNUPGHOME`, manages the three known GPG configuration files, and imports the
personal private key. A work render removes only those previously managed
configuration files and contains no personal GPG retrieval command. It never
removes the GPG home directory because that directory may contain unmanaged keys
or data.

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
settings. Profile-specific identity and signing values are rendered only from
the active profile's machine-local data.

### Personal machine profile

The personal profile may enable personal credentials, personal applications,
and opinionated macOS configuration.

### Work machine profile

The work profile may use the same XDG layout and shared development environment,
but must not retrieve, store, import, or expose personal GPG material. It
configures only its work identity and work SSH signing public key.

## XDG migrations and removal

Root-level files can be removed when they are deliberately replaced by managed
XDG targets and the migration applies to every managed machine. Before removal,
inspect and migrate any useful contents.

The current intended migrations are:

- `~/.gitconfig` to `~/.config/git/config`;
- `~/.zprofile` to `~/.config/zsh/.zprofile`, after `~/.zshenv` sets `ZDOTDIR`;
- `~/.zsh_history` to `~/.local/state/zsh/history`;
- removal of `~/.zsh_sessions` after Apple shell sessions are disabled.

Temporary removal sources also clean up the superseded Git profile fragments
and public-key targets (`personal`, `work`, `work_allowed_signers`,
`keys/personal.pub`, and `keys/work.pub`). Remove those migration markers only
after every managed machine has crossed this migration.

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
