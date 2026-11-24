#!/usr/bin/env bash

set -euo pipefail

pam_target="/etc/pam.d/sudo_local"
pam_tmp=""
cleanup() {
    if [[ -n "$pam_tmp" && -f "$pam_tmp" ]]; then
        rm -f -- "$pam_tmp"
    fi
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

pam_tmp=$(mktemp "${TMPDIR:-/tmp}/chezmoi-sudo-local.XXXXXX")
cat <<'EOF' >"$pam_tmp"
# sudo_local: local config file which survives system update and is included for sudo
auth       sufficient     pam_tid.so
EOF

if ! cmp -s "$pam_tmp" "$pam_target" 2>/dev/null; then
    sudo install -o root -g wheel -m 0444 "$pam_tmp" "$pam_target"
fi
