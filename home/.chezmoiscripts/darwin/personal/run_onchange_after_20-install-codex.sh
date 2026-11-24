#!/usr/bin/env bash

set -euo pipefail

codex_bin="$HOME/.local/bin/codex"

if [[ ! -x "$codex_bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
fi

"$codex_bin" --version

echo "✓ Installed Codex CLI"
