#!/usr/bin/env bash

set -euo pipefail

if pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
    exit 0
fi

echo "Installing Rosetta 2..."
sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
