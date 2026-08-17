# Machine profiles

This repository manages configuration for personal and work machines on macOS
and Linux. Each machine selects exactly one profile. The selection is stored in
chezmoi's machine-local configuration, not in the repository.

This document defines durable policy. Current packages, paths, templates, and
machine state belong in the source or generated configuration rather than here.

## Safety policy

- Shared configuration must be safe and non-destructive on every profile.
- A profile must never retrieve or expose another profile's credentials.
- Work machines must not receive personal GPG or 1Password material.
- Profile-specific prompts and secret references belong in machine-local
  configuration. Shared static, non-secret policy belongs in `.chezmoidata`.
- Ignoring a target makes it unmanaged; it does not remove material that already
  exists on a machine.

## Profile boundaries

### Shared

The shared layer contains portable, non-secret preferences and common tool
settings. It must not assume personal credentials, applications, or system
policy.

### Personal

The personal profile may enable personal credentials, GPG signing, applications,
and opinionated macOS configuration. It must not retrieve work credentials.

### Work

The work profile may use shared settings and tools, but configures only its work
identity and SSH signing public key. Personal credentials, GPG material, personal
applications, and personal system policy remain unmanaged.

## Git and SSH

The active profile supplies one default Git identity and signing method:
personal uses GPG and work uses SSH signing. `user.useConfigOnly` prevents Git
from guessing a missing identity.

Reference repositories, opposite-profile repositories, and the chezmoi source
on work use a no-identity guard. It clears the default identity and sets
`push.default = nothing`. This is a workflow safeguard, not an access-control
boundary: local configuration and environment variables can override it, and an
explicit push can bypass it. Forge permissions and credentials provide the real
security boundary.

SSH authentication is separate from Git identity and signing. It is selected by
SSH host configuration and the 1Password SSH agent, not by repository location.
Forge directories are organizational only.

Work's allowed-signers mapping enables local verification of SSH-signed commits
and tags. It is not used to create signatures, authenticate over SSH, or decide
a forge's verification status. Each forge maintains its own signing-key registry.

## Platform policy

Shared configuration should remain portable across macOS and Linux. Automated
package installation and system configuration target Apple Silicon macOS.
Linux-specific prerequisites remain external and must be validated on each
machine.

Persistent machine capability, such as `headless`, controls whether
browser-dependent behavior is appropriate. Current terminal interactivity must
not stand in for machine capability.

## Validation

Changes affecting profiles must be rendered with representative, non-secret data
for both profiles. Validation must not retrieve real secrets or print secret
values.

Before applying, inspect the ignored and managed targets, review a verbose diff
and dry run, and prefer explicit targets. A full apply may install software,
request administrator privileges, or change system settings.

After applying, check the effective profile and account, Git signing, SSH
authentication, no-identity guards, and absence of opposite-profile credentials.
Validation results are machine state and must not be recorded in this document.
