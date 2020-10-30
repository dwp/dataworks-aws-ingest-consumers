#!/bin/sh

K2HB_APPLICATION_NAME=$1

PIDFILE="/var/run/k2hb.pid"

# Import the logging functions
source /opt/k2hb/logging.sh

function log_shell_message() {
  log_k2hb_message "${1}" "respawn_k2hb.sh" "NOT_SET" "${K2HB_APPLICATION_NAME}" "${@:2}"
}

if [[ -f $PIDFILE ]]; then
  PID=$(cat $PIDFILE)
  if [[ ! -z $PID ]]; then
    RUNNING=$(ps --no-headers $PID)
    if [[ -z $RUNNING ]]; then
      log_shell_message "K2HB has stopped running, will attempt to restart it"
      /sbin/service k2hb start
    fi
  fi
fi
