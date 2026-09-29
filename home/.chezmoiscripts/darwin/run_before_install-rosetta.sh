#!/usr/bin/env bash

set -euo pipefail

if arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
    exit 0
fi

echo "Installing Rosetta 2..."
sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
