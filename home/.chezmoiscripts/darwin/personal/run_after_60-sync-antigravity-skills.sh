#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

target_dir="$HOME/.gemini/config/skills"
shared_dir="$HOME/.agents/skills"
pi_ponytail_dir="$HOME/.pi/agent/npm/node_modules/@dietrichgebert/ponytail/skills"
copilot_ponytail_dir="$HOME/.copilot/installed-plugins/ponytail/ponytail/skills"

if [[ -L "$target_dir" ]]; then
    rm -- "$target_dir"
fi
mkdir -p "$target_dir"

source_dirs=()
if [[ -d "$shared_dir" ]]; then
    source_dirs+=("$shared_dir")
fi
if [[ -d "$pi_ponytail_dir" ]]; then
    source_dirs+=("$pi_ponytail_dir")
elif [[ -d "$copilot_ponytail_dir" ]]; then
    source_dirs+=("$copilot_ponytail_dir")
fi

desired_names="|"

if ((${#source_dirs[@]} > 0)); then
    for source_dir in "${source_dirs[@]}"; do
        for skill_dir in "$source_dir"/*; do
            if [[ ! -d "$skill_dir" || ! -f "$skill_dir/SKILL.md" ]]; then
                continue
            fi

            skill_name="${skill_dir##*/}"
            if [[ "$desired_names" == *"|$skill_name|"* ]]; then
                continue
            fi
            desired_names="${desired_names}${skill_name}|"

            link_path="$target_dir/$skill_name"
            if [[ -e "$link_path" && ! -L "$link_path" ]]; then
                continue
            fi

            if [[ ! -L "$link_path" || "$(readlink "$link_path")" != "$skill_dir" ]]; then
                ln -sfn "$skill_dir" "$link_path"
            fi
        done
    done
fi

for existing in "$target_dir"/*; do
    if [[ ! -L "$existing" ]]; then
        continue
    fi

    if [[ ! -e "$existing" ]]; then
        rm -- "$existing"
        continue
    fi

    existing_name="${existing##*/}"
    existing_target="$(readlink "$existing")"
    case "$existing_target" in
        "$shared_dir"/* | "$pi_ponytail_dir"/* | "$copilot_ponytail_dir"/*)
            if [[ "$desired_names" != *"|$existing_name|"* ]]; then
                rm -- "$existing"
            fi
            ;;
    esac
done
