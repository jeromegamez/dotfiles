#!/usr/bin/env bash

set -euo pipefail

agy_bin="$HOME/.local/bin/agy"

if [[ ! -x "$agy_bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir "$HOME/.local/bin"
fi

"$agy_bin" --version

echo "✓ Installed Antigravity CLI"
