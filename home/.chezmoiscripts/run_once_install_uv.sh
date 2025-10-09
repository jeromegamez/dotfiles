#!/usr/bin/env bash

# Install uv via standalone installer
# This script runs once via chezmoi to install uv
# Using standalone installer allows self-updates via `uv self update`

set -euo pipefail

echo "Installing uv..."

# Install uv using the official standalone installer
curl -fsSL https://astral.sh/uv/install.sh | sh

echo "uv installation completed!"

# Verify installation
if command -v uv >/dev/null 2>&1; then
    echo "✓ uv installed successfully"
    echo "Location: $(which uv)"
    echo "Version: $(uv --version)"
else
    echo "✗ uv installation may have failed"
    echo "Try running the installation command manually:"
    echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
fi
