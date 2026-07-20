#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for dependency in chezmoi shellcheck shfmt; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        echo "Missing dependency: $dependency" >&2
        exit 1
    fi
done

lint_data='{
    "profile": "personal",
    "work": false,
    "personal": true,
    "name": "Test User",
    "email": "test@example.invalid",
    "onepasswordAccount": "test",
    "homebrewPrefix": "/opt/homebrew",
    "credentials": {
        "githubToken": "test",
        "githubComposerToken": "test",
        "gitlabToken": "test"
    },
    "git": {
        "name": "Test User",
        "email": "test@example.invalid",
        "signingKey": "test"
    },
    "versions": {
        "phpVersions": ["8.4", "8.5"]
    },
    "macos": {
        "timezone": "Europe/Berlin"
    }
}'

rendered_file=""
cleanup() {
    if [[ -n "$rendered_file" && -f "$rendered_file" ]]; then
        unlink "$rendered_file"
    fi
}
trap cleanup EXIT

rendered_file=$(mktemp "${TMPDIR:-/tmp}/chezmoi-shell-lint.XXXXXX")
checked=0

while IFS= read -r -d '' file; do
    if [[ "$(head -n 1 "$file")" != '#!/usr/bin/env bash' ]]; then
        continue
    fi

    if [[ "$file" == *.tmpl ]]; then
        echo "Linting rendered template: $file"
        chezmoi execute-template \
            --config /dev/null \
            --config-format toml \
            --source "$repo_root/home" \
            --override-data "$lint_data" \
            <"$file" >"$rendered_file"
        shellcheck -s bash "$rendered_file"
        shfmt -d -ln bash -i 4 -ci "$rendered_file"
    else
        echo "Linting: $file"
        shellcheck -s bash "$file"
        shfmt -d -ln bash -i 4 -ci "$file"
    fi

    checked=$((checked + 1))
done < <(
    find home scripts -type f \
        \( -name '*.sh' -o -name '*.bash' -o -name '*.tmpl' -o -name 'executable_*' -o -perm -111 \) \
        -print0
)

echo "Shell lint passed for $checked files."
