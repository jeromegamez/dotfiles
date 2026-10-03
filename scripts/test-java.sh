#!/usr/bin/env bash

# The sourced hook invokes the sudo mock.
# shellcheck disable=SC1090,SC1091,SC2329

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-test-java.XXXXXX")
test_dir="$(cd "$test_dir" && pwd)"
trap 'rm -rf -- "$test_dir"' EXIT

jdk_bundle="$test_dir/opt/openjdk/libexec/openjdk.jdk"
mkdir -p "$jdk_bundle" "$test_dir/registrations"
system_jdk="$test_dir/registrations/openjdk.jdk"

rendered_script="$test_dir/register-java.sh"
chezmoi --verbose execute-template \
    --config /dev/null \
    --config-format toml \
    --source "$repo_root/home" \
    --override-data "{\"homebrewPrefix\": \"$test_dir\"}" \
    <"$repo_root/home/.chezmoiscripts/darwin/run_onchange_after_1-register-homebrew-java.sh.tmpl" |
    sed "s|/Library/Java/JavaVirtualMachines|$test_dir/registrations|g" >"$rendered_script"

sudo() {
    echo "Unexpected sudo invocation" >&2
    return 1
}
(
    sudo() { "$@"; }
    source "$rendered_script"
)
[[ "$(readlink "$system_jdk")" == "$jdk_bundle" ]]
(source "$rendered_script")

unlink "$system_jdk"
ln -s "$test_dir/unrelated-jdk" "$system_jdk"
if (source "$rendered_script" 2>/dev/null); then
    echo "The hook replaced an unrelated registration" >&2
    exit 1
fi
[[ "$(readlink "$system_jdk")" == "$test_dir/unrelated-jdk" ]]

echo "Java registration hook checks passed."
