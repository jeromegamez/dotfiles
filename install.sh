#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# Install Xcode Command Line Tools, if needed
if [ "${OSTYPE#darwin}" != "$OSTYPE" ]; then
  if ! xcode-select --print-path >/dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools"
    xcode-select --install &> /dev/null

    # Wait until the tools are installed
    while ! xcode-select --print-path >/dev/null 2>&1; do
      sleep 5
    done
  fi

  if ! command -v brew >/dev/null 2>&1 ; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Install chezmoi, if needed
if ! chezmoi="$(command -v chezmoi)"; then
    bin_dir="${HOME}/.local/bin"
    chezmoi="${bin_dir}/chezmoi"
    echo "Installing chezmoi to '${chezmoi}'" >&2
    if command -v curl >/dev/null; then
        chezmoi_install_script="$(curl -fsSL get.chezmoi.io)"
    elif command -v wget >/dev/null; then
        chezmoi_install_script="$(wget -qO- get.chezmoi.io)"
    else
        echo "To install chezmoi, you must have curl or wget installed." >&2
        exit 1
    fi
    sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
    unset chezmoi_install_script bin_dir
fi

set -- init --apply jeromegamez

echo "Running 'chezmoi $*'" >&2
# exec: replace current process with chezmoi
exec "$chezmoi" "$@"
