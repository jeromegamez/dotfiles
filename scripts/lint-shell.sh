#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for dependency in chezmoi shellcheck shfmt zsh python3 jq; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        echo "Missing dependency: $dependency" >&2
        exit 1
    fi
done

personal_lint_data='{
    "profile": "personal",
    "work": false,
    "personal": true,
    "email": "test@example.invalid",
    "onepasswordAccount": "test",
    "githubRateLimitTokenReference": "op://test/test/token",
    "homebrewPrefix": "/opt/homebrew"
}'

work_lint_data='{
    "profile": "work",
    "work": true,
    "personal": false,
    "email": "test@example.invalid",
    "workGitSigningPublicKey": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITestKeyForTemplateRenderingOnly",
    "onepasswordAccount": "test",
    "githubRateLimitTokenReference": "op://test/test/token",
    "homebrewPrefix": "/opt/homebrew"
}'

linux_lint_data='{
    "profile": "personal",
    "work": false,
    "personal": true,
    "email": "test@example.invalid",
    "onepasswordAccount": "test",
    "githubRateLimitTokenReference": "op://test/test/token",
    "chezmoi": {
        "os": "linux",
        "arch": "amd64"
    }
}'

temp_dir=""
cleanup() {
    if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
        rm -rf -- "$temp_dir"
    fi
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-lint.XXXXXX")
rendered_file="$temp_dir/rendered"
pycache_dir="$temp_dir/pycache"
checked=0
failures=0

record_failure() {
    failures=$((failures + 1))
}

render_template() {
    local file="$1"
    local lint_data="$2"

    chezmoi --verbose execute-template \
        --config /dev/null \
        --config-format toml \
        --source "$repo_root/home" \
        --override-data "$lint_data" \
        <"$file" >"$rendered_file"
}

while IFS= read -r -d '' file; do
    if [[ "$file" == *.tmpl ]]; then
        bash_checked=false
        for profile in personal work; do
            case "$profile" in
                personal) lint_data="$personal_lint_data" ;;
                work) lint_data="$work_lint_data" ;;
            esac

            if ! render_template "$file" "$lint_data"; then
                echo "Template render failed ($profile): $file" >&2
                record_failure
                continue
            fi

            if [[ "$(head -n 1 "$rendered_file")" != '#!/usr/bin/env bash' ]]; then
                continue
            fi

            bash_checked=true
            echo "Linting rendered bash template ($profile): $file"
            shellcheck -s bash "$rendered_file" || record_failure
            shfmt -d -ln bash -i 4 -ci "$rendered_file" || record_failure
        done
        if [[ "$bash_checked" == true ]]; then
            checked=$((checked + 1))
        fi
    else
        if [[ "$(head -n 1 "$file")" != '#!/usr/bin/env bash' ]]; then
            continue
        fi
        echo "Linting bash: $file"
        shellcheck -s bash "$file" || record_failure
        shfmt -d -ln bash -i 4 -ci "$file" || record_failure
        checked=$((checked + 1))
    fi
done < <(
    find home scripts -type f \
        \( -name '*.sh' -o -name '*.sh.tmpl' -o -name '*.bash' -o -name '*.bash.tmpl' -o -name 'executable_*' -o -perm -111 \) \
        -print0
)

for zsh_file in \
    home/private_dot_zshenv.tmpl \
    home/private_dot_config/private_zsh/aliases.zsh \
    home/private_dot_config/private_zsh/dot_zprofile.tmpl \
    home/private_dot_config/private_zsh/dot_zshrc.tmpl \
    home/private_dot_config/private_zsh/tools.zsh.tmpl; do
    if [[ "$zsh_file" == *.tmpl ]]; then
        for profile in personal work linux; do
            case "$profile" in
                personal) lint_data="$personal_lint_data" ;;
                work) lint_data="$work_lint_data" ;;
                linux) lint_data="$linux_lint_data" ;;
            esac
            echo "Linting rendered zsh template ($profile): $zsh_file"
            if render_template "$zsh_file" "$lint_data"; then
                zsh -n "$rendered_file" || record_failure
            else
                record_failure
            fi
        done
    else
        echo "Linting zsh: $zsh_file"
        zsh -n "$zsh_file" || record_failure
    fi
    checked=$((checked + 1))
done

while IFS= read -r -d '' py_file; do
    echo "Linting python: $py_file"
    PYTHONPYCACHEPREFIX="$pycache_dir" python3 -m py_compile "$py_file" || record_failure
    checked=$((checked + 1))
done < <(find home scripts -type f -name '*.py' -print0)

echo "Testing SSH generator scripts: scripts/test_ssh_generators.py"
PYTHONPYCACHEPREFIX="$pycache_dir" python3 scripts/test_ssh_generators.py || record_failure
checked=$((checked + 1))

for modify_file in \
    home/private_dot_pi/agent/modify_private_settings.json \
    home/dot_gemini/antigravity-cli/modify_private_settings.json \
    home/private_dot_config/private_karabiner/modify_private_karabiner.json; do
    for stdin_label in empty object; do
        case "$stdin_label" in
            empty) stdin_json="" ;;
            object) stdin_json="{}" ;;
        esac
        modify_data="$(jq --arg stdin "$stdin_json" '. + {chezmoi: {stdin: $stdin}}' <<<"$personal_lint_data")"
        echo "Linting modify template ($stdin_label): $modify_file"
        if render_template "$modify_file" "$modify_data"; then
            jq empty "$rendered_file" >/dev/null || record_failure
        else
            record_failure
        fi
    done
    checked=$((checked + 1))
done

if ((failures > 0)); then
    echo "Lint failed with $failures error(s)." >&2
    exit 1
fi

echo "Lint passed for $checked files."
