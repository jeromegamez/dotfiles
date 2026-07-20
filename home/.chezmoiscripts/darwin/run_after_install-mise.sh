#!/usr/bin/env bash

set -euo pipefail

temp_dir=""
cleanup() {
    if [[ -n "${temp_dir:-}" && -d "$temp_dir" ]]; then
        rm -f -- "$temp_dir/mise-install.sh"
        rmdir -- "$temp_dir" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

MISE_BIN="${HOME}/.local/bin/mise"
MISE_CMD="$(command -v mise || true)"
if [[ -z "$MISE_CMD" && -x "$MISE_BIN" ]]; then
    MISE_CMD="$MISE_BIN"
fi

refresh_mise_cmd() {
    MISE_CMD="$(command -v mise || true)"
    if [[ -z "$MISE_CMD" && -x "$MISE_BIN" ]]; then
        MISE_CMD="$MISE_BIN"
    fi
}

update_mise_binary() {
    local before after

    before="$($MISE_CMD --version 2>/dev/null || true)"
    if "$MISE_CMD" self-update -y --no-plugins; then
        after="$($MISE_CMD --version 2>/dev/null || true)"
        if [[ -n "$before" && "$before" != "$after" ]]; then
            echo "✓ mise updated: $before -> $after"
        else
            echo "✓ mise already latest: ${after:-unknown}"
        fi
    else
        echo "Warning: mise self-update failed"
    fi

    refresh_mise_cmd
}

ensure_node_lts() {
    if ! "$MISE_CMD" upgrade node@lts; then
        echo "Warning: mise upgrade node@lts failed"
    fi
}

if [[ -n "$MISE_CMD" ]]; then
    echo "✓ mise already installed: $($MISE_CMD --version)"
    update_mise_binary
    ensure_node_lts
    echo "✓ Node LTS ensured via mise"
    exit 0
fi

echo "Installing mise..."

temp_dir=$(mktemp -d)
installer="$temp_dir/mise-install.sh"

curl -fsSL https://mise.run -o "$installer"

if [[ ! -s "$installer" ]]; then
    echo "✗ mise installer download failed"
    exit 1
fi

sh "$installer"

MISE_CMD="$(command -v mise || true)"
if [[ -z "$MISE_CMD" && -x "$MISE_BIN" ]]; then
    MISE_CMD="$MISE_BIN"
fi

if [[ -z "$MISE_CMD" ]]; then
    echo "✗ mise installation failed"
    exit 1
fi

echo "✓ mise installed successfully: $($MISE_CMD --version)"
ensure_node_lts
echo "✓ Node LTS ensured via mise"
