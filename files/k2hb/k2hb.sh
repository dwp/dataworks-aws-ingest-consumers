#!/bin/bash

unset http_proxy
unset HTTP_PROXY
unset https_proxy
unset HTTPS_PROXY
unset no_proxy
unset NO_PROXY

source /opt/k2hb/settings
/opt/k2hb/bin/kafka2hbase &
