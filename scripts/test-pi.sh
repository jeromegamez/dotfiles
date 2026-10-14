#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-test-pi.XXXXXX")
test_dir="$(cd "$test_dir" && pwd)"
trap 'rm -rf -- "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/runtime/bin"
export PI_TEST_LOG="$test_dir/commands.log"
export PI_TEST_RUNTIME="$test_dir/runtime/bin"
export PI_TEST_INSTALLER="$test_dir/installer.sh"

cat >"$test_dir/bin/mise" <<'MISE'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == exec && "$2" == node@* && "$3" == -- ]]
export PI_TEST_NODE="$2"
shift 3
export PATH="$PI_TEST_RUNTIME:$PATH"
exec "$@"
MISE

cat >"$test_dir/bin/curl" <<'CURL'
#!/usr/bin/env bash
set -euo pipefail
[[ "$*" == "-fsSL https://pi.dev/install.sh -o "* ]]
printf 'download\n' >>"$PI_TEST_LOG"
cp "$PI_TEST_INSTALLER" "$4"
CURL

cat >"$test_dir/runtime/bin/npm" <<'NPM'
#!/usr/bin/env bash
set -euo pipefail
[[ -n "$PI_TEST_NODE" ]]
[[ "$*" == "uninstall --global --ignore-scripts --prefix "* ]]
prefix="$5"
# Only separate Homebrew cleanup belongs to the hook, not npm migration.
[[ "$prefix" == "${PI_TEST_RUNTIME%/runtime/bin}" ]]
[[ -x "$HOME/.pi/agent/bin/pi" && -f "$HOME/.pi/agent/install/current-version" ]]
printf 'uninstall:%s\n' "$prefix" >>"$PI_TEST_LOG"
rm -rf -- "$prefix/lib/node_modules/@earendil-works/pi-coding-agent"
rm -f -- "$prefix/bin/pi"
NPM

cat >"$PI_TEST_INSTALLER" <<'INSTALLER'
#!/bin/sh
set -eu
[ -n "$PI_TEST_NODE" ]
[ "$PI_CODING_AGENT_DIR" = "$HOME/.pi/agent" ]
# The wrapper and Homebrew must not participate in discovery or link placement.
[ "$PATH" = "$PI_TEST_RUNTIME:$XDG_DATA_HOME/pi/bin:$HOME/.pi/agent/bin:/usr/bin:/bin:/usr/sbin:/sbin" ]
existing_pi=$(command -v pi || true)
if [ -x "$XDG_DATA_HOME/pi/bin/pi" ]; then
    [ "$existing_pi" = "$XDG_DATA_HOME/pi/bin/pi" ]
else
    [ -z "$existing_pi" ]
fi
printf 'install:%s\n' "$existing_pi" >>"$PI_TEST_LOG"
[ "${PI_TEST_FAIL_INSTALL:-0}" = 0 ] || exit 1
[ "${PI_TEST_ACTION:-install}" != none ] || exit 0
mkdir -p "$PI_CODING_AGENT_DIR/bin" "$PI_CODING_AGENT_DIR/install"
cat >"$PI_CODING_AGENT_DIR/bin/pi" <<'PI'
#!/usr/bin/env bash
set -euo pipefail
[[ -n "$PI_TEST_NODE" ]]
printf 'managed:%s\n' "$*" >>"$PI_TEST_LOG"
if [[ "$*" == --version ]]; then
    printf '1.2.0\n'
fi
PI
chmod +x "$PI_CODING_AGENT_DIR/bin/pi"
printf '1.2.0\n' >"$PI_CODING_AGENT_DIR/install/current-version"
# The upstream installer owns removal of the npm installation it discovered.
if [ -n "$existing_pi" ]; then
    printf 'installer-uninstall:%s\n' "$existing_pi" >>"$PI_TEST_LOG"
    rm -f -- "$existing_pi"
    rm -rf -- "$XDG_DATA_HOME/pi/lib/node_modules/@earendil-works/pi-coding-agent"
fi
INSTALLER
chmod +x "$test_dir/bin/"* "$test_dir/runtime/bin/npm"

render() {
    chezmoi --verbose execute-template \
        --config /dev/null \
        --config-format toml \
        --source "$repo_root/home" \
        --override-data "{\"homebrewPrefix\": \"$test_dir\", \"agentAddons\": {\"pi\": {\"packages\": [\"npm:fixture-addon\"]}}}" \
        <"$repo_root/$1"
}

render home/.chezmoiscripts/darwin/run_onchange_after_3-install-pi.sh.tmpl >"$test_dir/install-pi.sh"
render home/private_dot_local/private_bin/executable_pi.tmpl >"$test_dir/pi"
render home/.chezmoiscripts/darwin/run_onchange_after_5-install-agent-addons.sh.tmpl >"$test_dir/addons.sh"

export PATH="$test_dir/bin:$PATH"
export HOME="$test_dir/home"
export XDG_DATA_HOME="$test_dir/data"
mkdir -p "$HOME/.local/bin" "$XDG_DATA_HOME/pi/bin" \
    "$XDG_DATA_HOME/pi/lib/node_modules/@earendil-works/pi-coding-agent" \
    "$test_dir/lib/node_modules/@earendil-works/pi-coding-agent"
cp "$test_dir/pi" "$HOME/.local/bin/pi"
chmod +x "$HOME/.local/bin/pi"
printf '#!/usr/bin/env bash\nprintf "legacy\\n"\n' >"$XDG_DATA_HOME/pi/bin/pi"
chmod +x "$XDG_DATA_HOME/pi/bin/pi"

# Failed migration keeps the legacy installation usable and skips cleanup.
if PI_TEST_FAIL_INSTALL=1 bash "$test_dir/install-pi.sh"; then
    echo "Failed installer was accepted" >&2
    exit 1
fi
[[ "$("$HOME/.local/bin/pi" --version)" == legacy ]]
[[ -d "$XDG_DATA_HOME/pi/lib/node_modules/@earendil-works/pi-coding-agent" ]]
if grep -q '^uninstall:' "$PI_TEST_LOG"; then
    echo "Failed migration removed a legacy installation" >&2
    exit 1
fi

# Declining migration must succeed without deleting either old installation.
PI_TEST_ACTION=none bash "$test_dir/install-pi.sh"
[[ "$("$HOME/.local/bin/pi" --version)" == legacy ]]
[[ -d "$XDG_DATA_HOME/pi/lib/node_modules/@earendil-works/pi-coding-agent" ]]
[[ -d "$test_dir/lib/node_modules/@earendil-works/pi-coding-agent" ]]

# The installer removes npm Pi; the hook only cleans the separate Homebrew prefix.
bash "$test_dir/install-pi.sh"
grep -qx "installer-uninstall:$XDG_DATA_HOME/pi/bin/pi" "$PI_TEST_LOG"
[[ "$("$HOME/.local/bin/pi" --version)" == 1.2.0 ]]
[[ ! -e "$XDG_DATA_HOME/pi/bin/pi" ]]
[[ ! -d "$test_dir/lib/node_modules/@earendil-works/pi-coding-agent" ]]
"$HOME/.local/bin/pi" update --all
grep -qx 'managed:update --all' "$PI_TEST_LOG"

# Existing managed installations must not be downloaded or upgraded by chezmoi.
: >"$PI_TEST_LOG"
bash "$test_dir/install-pi.sh"
if grep -Eq '^(download|install|uninstall):?' "$PI_TEST_LOG"; then
    echo "Existing managed installation was changed" >&2
    exit 1
fi

# Add-on settings retain unrelated keys and drop the legacy global npm prefix.
printf '{"theme":"test","npmCommand":["old"],"packages":[]}\n' >"$HOME/.pi/agent/settings.json"
mkdir -p "$HOME/.pi/agent/npm/node_modules/fixture-addon"
bash "$test_dir/addons.sh"
jq -e --arg mise "$test_dir/bin/mise" \
    '.theme == "test" and .npmCommand[0] == $mise
    and .npmCommand[1] == "exec" and (.npmCommand[2] | startswith("node@"))
    and .npmCommand[3:] == ["--", "npm"]' "$HOME/.pi/agent/settings.json" >/dev/null

# Fresh machines must install without mistaking the new wrapper for legacy Pi.
export HOME="$test_dir/fresh-home"
export XDG_DATA_HOME="$test_dir/fresh-data"
mkdir -p "$HOME/.local/bin"
cp "$test_dir/pi" "$HOME/.local/bin/pi"
chmod +x "$HOME/.local/bin/pi"
# Cancellation on a fresh machine must not make the add-ons hook invoke missing Pi.
PI_TEST_ACTION=none bash "$test_dir/install-pi.sh"
[[ ! -e "$HOME/.pi/agent/bin/pi" ]]
bash "$test_dir/addons.sh"
[[ ! -d "$HOME/.pi/agent/npm/node_modules/fixture-addon" ]]
bash "$test_dir/install-pi.sh"
[[ "$("$HOME/.local/bin/pi" --version)" == 1.2.0 ]]

echo "Pi migration and launcher checks passed."
