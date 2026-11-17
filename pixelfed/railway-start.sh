#!/bin/sh
# Runs as www-data after the image's entrypoint has migrated the database.
# One-time setup, then the queue worker and scheduler in the background,
# then the web server in the foreground.
set -u
cd /var/www/html
M=storage/app/.railway
mkdir -p "$M"

# OAuth keys live on the volume, so tokens survive redeploys.
if [ ! -f storage/oauth-private.key ]; then
  php artisan passport:keys --no-interaction
fi
if [ ! -f "$M/personal-client" ]; then
  php artisan passport:client --personal --name="Pixelfed Personal Access Client" --no-interaction \
    && touch "$M/personal-client"
fi

# The instance actor signs federation requests (idempotent).
php artisan instance:actor

# First admin, only while the database has no accounts.
users="$(php /usr/local/bin/user-count.php 2>&1 | tail -n 1)"
echo "pixelfed-railway: accounts in the database: $users"
if [ "$users" = "0" ]; then
  if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
    php artisan user:create --name="${ADMIN_NAME:-Admin}" --username="${ADMIN_USERNAME:-admin}" \
      --email="$ADMIN_EMAIL" --password="$ADMIN_PASSWORD" --is_admin=true --confirm_email=1 \
      && echo "pixelfed-railway: created admin ${ADMIN_USERNAME:-admin} <$ADMIN_EMAIL>"
  else
    echo "pixelfed-railway: no ADMIN_EMAIL/ADMIN_PASSWORD set, no admin created"
  fi
fi

# Location data for posts, imported once in the background.
if [ ! -f "$M/cities" ]; then
  ( php artisan import:cities >/dev/null && touch "$M/cities" \
      && echo "pixelfed-railway: imported cities" ) &
fi

# Queue worker (media processing, federation, notifications) and scheduler.
( while :; do php artisan horizon; echo "pixelfed-railway: horizon exited, restarting in 5 s"; sleep 5; done ) &
( while :; do php artisan schedule:work; echo "pixelfed-railway: scheduler exited, restarting in 5 s"; sleep 5; done ) &

exec frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile
