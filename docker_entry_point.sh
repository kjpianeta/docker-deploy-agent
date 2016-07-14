#!/usr/bin/env bash

if [ "$1" = 'create' ]; then
    echo "Creating tenant"
fi

exec "$@"
