#!/bin/sh
set -e

if [ -n "$MROC_PASS" ]; then
    set -- --pass "$MROC_PASS" "$@"
fi

exec /mroc "$@"
