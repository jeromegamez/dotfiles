#!/usr/bin/env bash

# Install Claude Code native binary
# This script runs once via chezmoi to install Claude Code

set -euo pipefail

echo "Installing Claude Code..."

# Install Claude Code using the official installer
curl -fsSL https://claude.ai/install.sh | bash

echo "Claude Code installation completed!"

# Verify installation
if command -v claude >/dev/null 2>&1; then
    echo "✓ Claude Code installed successfully"
    echo "Location: $(which claude)"
else
    echo "✗ Claude Code installation may have failed"
    echo "Try running the installation command manually:"
    echo "curl -fsSL https://claude.ai/install.sh | bash"
fi
