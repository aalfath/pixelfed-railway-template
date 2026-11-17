#!/bin/sh
# Password from REDIS_PASSWORD, append-only file on the /data volume.
# Railway volumes are root-owned and contain lost+found, so the official
# entrypoint won't fix their ownership: keep the data in a redis-owned subfolder.
set -eu
: "${REDIS_PASSWORD:?REDIS_PASSWORD must be set}"
mkdir -p /data/redis
chown redis:redis /data/redis
cd /data/redis
exec docker-entrypoint.sh redis-server --requirepass "$REDIS_PASSWORD" \
  --appendonly yes --dir /data/redis --save 300 10
