#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-test-maintenance.XXXXXX")
test_dir="$(cd "$test_dir" && pwd)"
trap 'rm -rf -- "$test_dir"' EXIT
test_home="$test_dir/home with spaces"
test_bin_dir="$test_dir/user bin"
mkdir -p "$test_bin_dir" "$test_dir/bin" "$test_dir/runtime/bin"

export MAINTENANCE_TEST_LOG="$test_dir/commands.log"

render() {
    chezmoi --verbose execute-template \
        --config /dev/null \
        --config-format toml \
        --source "$repo_root/home" \
        --override-data "{\"homebrewPrefix\": \"$test_dir/runtime\"}" \
        <"$repo_root/$1"
}

run_script() {
    env HOME="$test_home" XDG_DATA_HOME="$test_dir/data" \
        XDG_BIN_DIR="$test_bin_dir" \
        PATH="$test_dir/bin:/usr/bin:/bin:/usr/sbin:/sbin" "$@"
}

render home/private_dot_local/private_bin/executable_maintenance.tmpl >"$test_dir/maintenance"

cat >"$test_dir/update-tool" <<'TOOL'
#!/usr/bin/env bash
set -euo pipefail
tool="${0##*/}"
printf '%s:%s\n' "$tool" "$*" >>"$MAINTENANCE_TEST_LOG"
[[ "${MAINTENANCE_TEST_FAIL:-}" != "$tool" ]]
TOOL
chmod +x "$test_dir/update-tool"
for tool in brew-maintenance chezmoi codex pi; do
    cp "$test_dir/update-tool" "$test_bin_dir/$tool"
done
cp "$test_dir/update-tool" "$test_dir/runtime/bin/mise"
cp "$test_dir/update-tool" "$test_dir/bin/gcloud"
cp "$test_dir/update-tool" "$test_dir/bin/gh"
mkdir -p "$test_home/.pi/agent/bin"
cp "$test_dir/update-tool" "$test_home/.pi/agent/bin/pi"

: >"$MAINTENANCE_TEST_LOG"
run_script bash "$test_dir/maintenance"
cat >"$test_dir/expected.log" <<'EXPECTED'
brew-maintenance:
chezmoi:--verbose upgrade
mise:upgrade --global
codex:update
gcloud:components update --quiet
pi:update --all
gh:extensions upgrade --all
EXPECTED
cmp "$test_dir/expected.log" "$MAINTENANCE_TEST_LOG"

# Stop at the failed updater instead of reporting success or running later steps.
: >"$MAINTENANCE_TEST_LOG"
if run_script env MAINTENANCE_TEST_FAIL=mise bash "$test_dir/maintenance"; then
    echo "Failed updater was accepted" >&2
    exit 1
fi
head -n 3 "$test_dir/expected.log" >"$test_dir/expected-short.log"
cmp "$test_dir/expected-short.log" "$MAINTENANCE_TEST_LOG"

# Profiles without optional tools, or with a Pi wrapper but no Pi, must still work.
chmod -x "$test_bin_dir/codex" "$test_home/.pi/agent/bin/pi"
mv "$test_dir/bin/gcloud" "$test_dir/gcloud"
mv "$test_dir/bin/gh" "$test_dir/gh"
: >"$MAINTENANCE_TEST_LOG"
run_script bash "$test_dir/maintenance"
cmp "$test_dir/expected-short.log" "$MAINTENANCE_TEST_LOG"

echo "Maintenance checks passed."
