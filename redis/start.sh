#!/bin/sh
# Password from REDIS_PASSWORD, append-only file on the /data volume.
set -eu
: "${REDIS_PASSWORD:?REDIS_PASSWORD must be set}"
exec docker-entrypoint.sh redis-server --requirepass "$REDIS_PASSWORD" \
  --appendonly yes --dir /data --save 300 10
