#!/usr/bin/env bash

set -eufo pipefail

PHP_BIN="$(command -v php || true)"
if [[ -z "$PHP_BIN" ]]; then
    echo "Skipping Composer setup because PHP is not installed"
    exit 0
fi

COMPOSER_PATH="${HOME}/.local/bin"
COMPOSER_FILE_NAME="composer"

if [ ! -f "${COMPOSER_PATH}/${COMPOSER_FILE_NAME}" ]
then
    mkdir -p "${COMPOSER_PATH}"
    EXPECTED_CHECKSUM="$("$PHP_BIN" -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    "$PHP_BIN" -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$("$PHP_BIN" -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
    then
        >&2 echo 'ERROR: Invalid installer checksum'
        rm composer-setup.php
        exit 1
    fi

    "$PHP_BIN" composer-setup.php --install-dir="${COMPOSER_PATH}" --filename="${COMPOSER_FILE_NAME}"
    rm composer-setup.php
fi

"$PHP_BIN" "${COMPOSER_PATH}/${COMPOSER_FILE_NAME}" global update --quiet --with-all-dependencies
