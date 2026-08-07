#!/usr/bin/env bash

set -euo pipefail

xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
xdg_bin_home="${XDG_BIN_HOME:-${XDG_BIN_DIR:-$HOME/.local/bin}}"
aws_install_dir="${xdg_data_home}/aws-cli"
aws_bin="${xdg_bin_home}/aws"
install_metadata="${aws_install_dir}/awscli/data/install.json"
temp_dir=""

cleanup() {
    if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
        rm -f -- "$temp_dir/install.sh"
        rmdir -- "$temp_dir" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

if [[ -x "$aws_bin" && -f "$install_metadata" ]]; then
    echo "✓ Official AWS CLI installation already exists"
    "$aws_bin" --version
    exit 0
fi

temp_dir=$(mktemp -d)
installer_script="${temp_dir}/install.sh"

echo "Installing the official AWS CLI..."
curl -fsSL "https://awscli.amazonaws.com/v2/install.sh" -o "$installer_script"
XDG_DATA_HOME="$xdg_data_home" XDG_BIN_HOME="$xdg_bin_home" bash "$installer_script"

if [[ ! -x "$aws_bin" || ! -f "$install_metadata" ]]; then
    echo "✗ Official AWS CLI installation could not be verified"
    exit 1
fi

"$aws_bin" --version
echo "✓ Official AWS CLI installed; run 'aws update' to update it"
