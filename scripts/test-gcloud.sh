#!/usr/bin/env bash

# The sourced hook invokes these command mocks.
# shellcheck disable=SC1090,SC2329

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-test-gcloud.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

fixture_dir="$test_dir/fixture/google-cloud-sdk"
mkdir -p "$fixture_dir/bin" "$test_dir/tmp"
printf '#!/usr/bin/env bash\nexit 0\n' >"$fixture_dir/bin/gcloud"
cat >"$fixture_dir/install.sh" <<'INSTALLER'
#!/usr/bin/env bash
touch "$(dirname "$0")/installed"
INSTALLER
chmod +x "$fixture_dir/bin/gcloud"
fixture_archive="$test_dir/sdk.tar.gz"
tar -czf "$fixture_archive" -C "$test_dir/fixture" google-cloud-sdk

rendered_script="$test_dir/install-gcloud.sh"
chezmoi --verbose execute-template \
    --config /dev/null \
    --config-format toml \
    --source "$repo_root/home" \
    <"$repo_root/home/.chezmoiscripts/darwin/run_after_install-gcloud.sh.tmpl" >"$rendered_script"

(
    export XDG_DATA_HOME="$test_dir/data"
    export TMPDIR="$test_dir/tmp"
    export CHEZMOI_VERBOSE=1
    command() {
        if [[ "$*" == '-v gcloud' ]]; then
            return 1
        fi
        builtin command "$@"
    }
    curl() { cp "$fixture_archive" "$4"; }

    source "$rendered_script"
    [[ -x "$XDG_DATA_HOME/google-cloud-sdk/bin/gcloud" ]]
    [[ -f "$XDG_DATA_HOME/google-cloud-sdk/installed" ]]

    # An installed SDK must skip downloads on subsequent applies.
    curl() { exit 1; }
    source "$rendered_script"
)

echo "Google Cloud CLI hook checks passed."
