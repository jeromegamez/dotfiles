#!/usr/bin/env bash

# The sourced hook invokes these command mocks.
# shellcheck disable=SC1090,SC2329

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/home/.chezmoiscripts/darwin/run_before_install-rosetta.sh"

# An available Intel runtime must skip installation and administrator access.
(
    arch() { return 0; }
    sudo() { exit 1; }
    source "$script"
)

# A missing runtime must invoke Apple's installer with license acceptance.
(
    arch() { return 1; }
    installed=false
    sudo() {
        [[ "$*" == '/usr/sbin/softwareupdate --install-rosetta --agree-to-license' ]]
        installed=true
    }
    source "$script"
    "$installed"
)

# Installer errors must fail the hook.
if (
    arch() { return 1; }
    sudo() { return 42; }
    source "$script"
); then
    echo "Rosetta installation failure was ignored" >&2
    exit 1
else
    [[ $? -eq 42 ]]
fi

echo "Rosetta hook checks passed."
