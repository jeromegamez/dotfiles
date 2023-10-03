#!/usr/bin/env bash

set -eufo pipefail


BIN="${HOME}/.local/bin/gcloud"
INSTALL_SCRIPT="${XDG_DATA_HOME}/google-cloud-sdk/install.sh"

if [ ! -f "${BIN}}" ]
then
    $INSTALL_SCRIPT --usage-reporting false --path-update false --command-completion false --install-python false
fi
