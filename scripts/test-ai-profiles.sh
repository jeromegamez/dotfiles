#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

chezmoi_profile() {
    local profile="$1"
    shift
    local personal=false work=false
    if [[ "$profile" == personal ]]; then
        personal=true
    else
        work=true
    fi
    chezmoi --verbose --config /dev/null --config-format toml \
        --source "$repo_root/home" --refresh-externals=never \
        --override-data "{\"homebrewPrefix\":\"/opt/homebrew\",\"personal\":$personal,\"work\":$work}" "$@"
}

work_managed="$(chezmoi_profile work managed --include files,symlinks,scripts)"
personal_managed="$(chezmoi_profile personal managed --include files,symlinks,scripts)"
for target in \
    .chezmoiscripts/darwin/2-install-antigravity.sh \
    .chezmoiscripts/darwin/2-install-codex.sh \
    .chezmoiscripts/darwin/3-install-pi.sh \
    .chezmoiscripts/darwin/4-install-agent-skills.sh \
    .chezmoiscripts/darwin/5-install-agent-addons.sh \
    .agents/skills/memory/SKILL.md \
    .claude/CLAUDE.md \
    .claude/skills \
    .codex/AGENTS.md \
    .copilot/copilot-instructions.md \
    .config/opencode/AGENTS.md \
    .gemini/AGENTS.md \
    .gemini/config/skills \
    .local/bin/git-exclude-ai \
    .local/bin/pi \
    .pi/agent/models.json; do
    if grep -Fxq "$target" <<<"$work_managed"; then
        echo "Work unexpectedly manages $target" >&2
        exit 1
    fi
    if ! grep -Fxq "$target" <<<"$personal_managed"; then
        echo "Personal does not manage $target" >&2
        exit 1
    fi
done

work_brewfile="$(chezmoi_profile work execute-template '{{ includeTemplate "homebrew/Brewfile.tmpl" . }}')"
personal_brewfile="$(chezmoi_profile personal execute-template '{{ includeTemplate "homebrew/Brewfile.tmpl" . }}')"
for cask in antigravity chatgpt copilot-cli github-copilot-app t3-code; do
    if grep -Fq "cask \"$cask\"" <<<"$work_brewfile"; then
        echo "Work unexpectedly installs $cask" >&2
        exit 1
    fi
    if ! grep -Fq "cask \"$cask\"" <<<"$personal_brewfile"; then
        echo "Personal does not install $cask" >&2
        exit 1
    fi
done

if grep -Fq 'cask "openlogi"' <<<"$work_brewfile" ||
    ! grep -Fq 'cask "openlogi"' <<<"$personal_brewfile" ||
    grep -Fq 'cask "yaak"' <<<"$work_brewfile"; then
    echo "Work software exclusions are not reflected in the Brewfiles" >&2
    exit 1
fi

work_mise="$(chezmoi_profile work execute-template --file "$repo_root/home/private_dot_config/private_mise/config.toml.tmpl")"
personal_mise="$(chezmoi_profile personal execute-template --file "$repo_root/home/private_dot_config/private_mise/config.toml.tmpl")"
pi_node="$(chezmoi_profile personal execute-template '{{ .versions.node.pi | quote }}')"
if grep -Fq "$pi_node" <<<"$work_mise" || ! grep -Fq "$pi_node" <<<"$personal_mise"; then
    echo "Pi's Node runtime is not limited to the personal profile" >&2
    exit 1
fi

work_zshenv="$(chezmoi_profile work execute-template --file "$repo_root/home/private_dot_zshenv.tmpl")"
personal_zshenv="$(chezmoi_profile personal execute-template --file "$repo_root/home/private_dot_zshenv.tmpl")"
if grep -Fq '.opencode/bin' <<<"$work_zshenv" || ! grep -Fq '.opencode/bin' <<<"$personal_zshenv"; then
    echo "OpenCode PATH is not limited to the personal profile" >&2
    exit 1
fi

echo "AI profile checks passed."
