#!/bin/bash

source /opt/k2hb/common_logging.sh

log_k2hb_message() {
    set +u

    message="${1}"
    component="${2}"
    process_id="${3}"
    application="${4}"

    app_version="NOT_SET"
    if [ -f "/opt/k2hb/version" ]; then
        app_version=$(cat /opt/k2hb/version)
    fi

    log_level="NOT_SET"
    if [ -f "/opt/k2hb/log_level" ]; then
        log_level=$(cat /opt/k2hb/log_level)
    fi

    environment="NOT_SET"
    if [ -f "/opt/k2hb/environment" ]; then
        environment=$(cat /opt/k2hb/environment)
    fi

    log_message "${message}" "${log_level}" "${app_version}" "${process_id}" "${application}" "${component}" "${environment}" "${@:4}"
}
