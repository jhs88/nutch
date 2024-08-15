#!/bin/bash
# docker-entrypoint for Nutch docker
set -e

if [[ "$VERBOSE" == "yes" ]]; then
    set -x
fi

if ! [[ ${SEVER_PORT:-} =~ ^[0-9]+$ ]]; then
    SEVER_PORT=8001
    export SEVER_PORT
fi

if ! [[ ${NUTCH_HOME:-} ]]; then
    NUTCH_HOME=/opt/nutch/runtime/local
    export NUTCH_HOME
fi

# Set Essential variables
init-var-nutch

# when invoked with e.g.: docker run nutch -help
if [ "${1:0:1}" == '-' ]; then
    set -- nutch "$@"
fi

# execute command passed in as arguments.
# The Dockerfile has specified the PATH to include
# $NUTCH_HOME/source_nutch (for NUTCH) and $NUTCH_HOME/docker (for docker-specific scripts )
exec "$@"
