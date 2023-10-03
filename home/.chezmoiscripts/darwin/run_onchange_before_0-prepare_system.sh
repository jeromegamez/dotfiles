#!/usr/bin/env bash

set -eufo pipefail

declare arch

arch="$(uname -m)"

# Install Rosetta on an Apple Silicon
if [[ "${arch}" == arm64 ]] && ! [[ -f /Library/Apple/usr/share/rosetta/rosetta ]]; then
    softwareupdate --install-rosetta --agree-to-license
fi
