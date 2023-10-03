#!/usr/bin/env bash

set -eufo pipefail

COMPOSER_PATH="${HOME}/.local/bin"
COMPOSER_FILE_NAME="composer"

if [ ! -f "${COMPOSER_PATH}/${COMPOSER_FILE_NAME}" ]
then
    mkdir -p "${COMPOSER_PATH}"
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
    then
        >&2 echo 'ERROR: Invalid installer checksum'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --install-dir="${COMPOSER_PATH}" --filename="${COMPOSER_FILE_NAME}"
    rm composer-setup.php
fi

${COMPOSER_PATH}/${COMPOSER_FILE_NAME} global update --quiet --with-all-dependencies
