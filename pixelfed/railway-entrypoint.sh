#!/bin/sh
# Runs as root: sets Pixelfed's defaults, prepares the storage volume, then hands
# over to the image's own entrypoint (migrations, caches) as www-data.
set -eu

# Railway networking: Caddy listens on PORT; TLS ends at Railway's edge.
export CADDY_HTTP_PORT="${PORT:-8080}"
export SSL_MODE="${SSL_MODE:-off}"
export TRUSTED_PROXY="${TRUSTED_PROXY:-off}"
export TRUST_PROXIES="${TRUST_PROXIES:-*}"
export HEALTHCHECK_PATH="${HEALTHCHECK_PATH:-/api/service/health-check}"
export LOG_OUTPUT_LEVEL="${LOG_OUTPUT_LEVEL:-warn}"

# Instance URL. APP_DOMAIN is the federation identity: set it before the first start.
APP_DOMAIN="${APP_DOMAIN:-${RAILWAY_PUBLIC_DOMAIN:-localhost}}"
export APP_DOMAIN
export APP_URL="${APP_URL:-https://$APP_DOMAIN}"
export ADMIN_DOMAIN="${ADMIN_DOMAIN:-$APP_DOMAIN}"

export APP_NAME="${APP_NAME:-Pixelfed}"
export APP_ENV="${APP_ENV:-production}"
export APP_DEBUG="${APP_DEBUG:-false}"
export LOG_CHANNEL="${LOG_CHANNEL:-stderr}"

# Database and Redis (hosts and passwords come from Railway reference variables).
export DB_CONNECTION="${DB_CONNECTION:-mysql}"
export DB_PORT="${DB_PORT:-3306}"
export DB_DATABASE="${DB_DATABASE:-pixelfed}"
export DB_USERNAME="${DB_USERNAME:-pixelfed}"
export REDIS_CLIENT="${REDIS_CLIENT:-phpredis}"
export REDIS_SCHEME="${REDIS_SCHEME:-tcp}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export CACHE_STORE="${CACHE_STORE:-redis}"
export CACHE_DRIVER="${CACHE_DRIVER:-$CACHE_STORE}"
export QUEUE_DRIVER="${QUEUE_DRIVER:-redis}"
export SESSION_DRIVER="${SESSION_DRIVER:-database}"
export BROADCAST_DRIVER="${BROADCAST_DRIVER:-log}"
export HORIZON_PREFIX="${HORIZON_PREFIX:-horizon-}"

# Federation on; sign-ups closed until the admin opens them.
export ACTIVITY_PUB="${ACTIVITY_PUB:-true}"
export AP_REMOTE_FOLLOW="${AP_REMOTE_FOLLOW:-true}"
export AP_INBOX="${AP_INBOX:-true}"
export AP_OUTBOX="${AP_OUTBOX:-true}"
export AP_SHAREDINBOX="${AP_SHAREDINBOX:-true}"
export OPEN_REGISTRATION="${OPEN_REGISTRATION:-false}"
export ENFORCE_EMAIL_VERIFICATION="${ENFORCE_EMAIL_VERIFICATION:-false}"
export OAUTH_ENABLED="${OAUTH_ENABLED:-true}"
export ENABLE_CONFIG_CACHE="${ENABLE_CONFIG_CACHE:-true}"
export INSTANCE_CONTACT_EMAIL="${INSTANCE_CONTACT_EMAIL:-${ADMIN_EMAIL:-}}"

# Mail: written to the log until you add SMTP settings (MAIL_MAILER=smtp, MAIL_HOST, ...).
export MAIL_MAILER="${MAIL_MAILER:-${MAIL_DRIVER:-log}}"
export MAIL_FROM_ADDRESS="${MAIL_FROM_ADDRESS:-pixelfed@$APP_DOMAIN}"
export MAIL_FROM_NAME="${MAIL_FROM_NAME:-$APP_NAME}"

# Queue workers (Horizon) sized for a small instance; raise them for a busy one.
export HORIZON_MAX_PROCESSES="${HORIZON_MAX_PROCESSES:-4}"
export HORIZON_FANOUT_MAX_PROCESSES="${HORIZON_FANOUT_MAX_PROCESSES:-2}"
export HORIZON_DELIVER_MAX_PROCESSES="${HORIZON_DELIVER_MAX_PROCESSES:-2}"
export HORIZON_MEDIA_MAX_PROCESSES="${HORIZON_MEDIA_MAX_PROCESSES:-2}"
export HORIZON_BACKGROUND_MAX_PROCESSES="${HORIZON_BACKGROUND_MAX_PROCESSES:-2}"

# PHP and the image's Laravel automations (migrations run on every start).
export PHP_OPCACHE_ENABLE="${PHP_OPCACHE_ENABLE:-1}"
export PHP_POST_MAX_SIZE="${PHP_POST_MAX_SIZE:-100M}"
export PHP_UPLOAD_MAX_FILE_SIZE="${PHP_UPLOAD_MAX_FILE_SIZE:-100M}"
export AUTORUN_ENABLED="${AUTORUN_ENABLED:-true}"
export AUTORUN_LARAVEL_MIGRATION="${AUTORUN_LARAVEL_MIGRATION:-true}"
export AUTORUN_LARAVEL_MIGRATION_TIMEOUT="${AUTORUN_LARAVEL_MIGRATION_TIMEOUT:-180}"
export AUTORUN_LARAVEL_STORAGE_LINK="${AUTORUN_LARAVEL_STORAGE_LINK:-true}"

S=/var/www/html/storage
if [ "$(id -u)" = "0" ]; then
  # Seed the volume with the image's storage tree; never overwrite existing files.
  cp -a --update=none /opt/pixelfed-storage/. "$S/"
  # Data files that ship with each release are refreshed on every start.
  cp -a /opt/pixelfed-storage/app/cities.json "$S/app/cities.json"
  cp -a /opt/pixelfed-storage/app/bouncer/all.json "$S/app/bouncer/all.json"
  rmdir "$S/lost+found" 2>/dev/null || true
  # A fresh Railway volume is owned by root.
  if [ "$(stat -c %u "$S")" != "33" ]; then
    echo "pixelfed-railway: giving the storage volume to www-data"
    chown -R www-data:www-data "$S"
  fi
  exec setpriv --reuid=www-data --regid=www-data --init-groups \
    env HOME=/tmp docker-php-serversideup-entrypoint "$@"
fi
exec docker-php-serversideup-entrypoint "$@"
