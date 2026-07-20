#!/usr/bin/env bash

# Install uv via standalone installer
# This script runs once via chezmoi to install uv
# Using standalone installer allows self-updates via `uv self update`

set -euo pipefail

cleanup() {
    if [[ -n "${tmp_dir:-}" && -d "$tmp_dir" ]]; then
        rm -f -- "$tmp_dir/uv-install.sh"
        rmdir -- "$tmp_dir" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

echo "Installing uv..."

tmp_dir=$(mktemp -d)
installer="$tmp_dir/uv-install.sh"

# Download installer first, then run it from disk.
# UV_NO_MODIFY_PATH=1 prevents installer from modifying shell config
# (PATH is already managed via zsh configuration)
curl -fsSL https://astral.sh/uv/install.sh -o "$installer"

if [[ ! -s "$installer" ]]; then
    echo "✗ uv installer download failed"
    exit 1
fi

env UV_NO_MODIFY_PATH=1 sh "$installer"

echo "uv installation completed!"

# Verify installation
if command -v uv >/dev/null 2>&1; then
    echo "✓ uv installed successfully"
    echo "Location: $(command -v uv)"
    echo "Version: $(uv --version)"
else
    echo "✗ uv installation may have failed"
    echo "Try running the installation command manually:"
    echo "curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh && sh /tmp/uv-install.sh"
    exit 1
fi
