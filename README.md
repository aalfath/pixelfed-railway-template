[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/pixelfed-1?utm_medium=integration&utm_source=button&utm_campaign=pixelfed)

# Pixelfed on Railway

A Railway template for [Pixelfed](https://pixelfed.org), the federated, ad-free photo sharing server (AGPL-3.0). It deploys three services, and each one builds from this repo:

| Service | Folder | Image (pinned by version and digest) | Volume |
|---|---|---|---|
| `Pixelfed` (web, queue worker, scheduler) | `pixelfed/` | `ghcr.io/pixelfed/pixelfed:v0.15.2` | `/var/www/html/storage` (uploads, OAuth keys, logs) |
| `MySQL` | `mysql/` | `mysql:8.4.13` (LTS) | `/var/lib/mysql` |
| `Redis` (cache and queues) | `redis/` | `redis:8.10.3-alpine` | `/data` (append-only file in `/data/redis`) |

## What you get

- Pixelfed v0.15.2 on a Railway domain with HTTPS, Railway health check on `/api/v1/instance` (public).
- Database migrations run on every start, so updates apply themselves.
- An admin account created on the first start from `ADMIN_EMAIL` (you enter it) and `ADMIN_PASSWORD` (generated). Log in with the email and password.
- OAuth keys, the instance actor (federation signing key) and the city list for post locations are set up on the first start.
- Horizon (the queue worker that processes media and federation) and the Laravel scheduler run inside the Pixelfed service.
- Sign-ups are closed until you open them in **Admin → Settings**, or set `OPEN_REGISTRATION=true`.
- Pixelfed's web installer stays closed: settings come from variables.

## Variables

| Service | Variable | Default | Notes |
|---|---|---|---|
| Pixelfed | `ADMIN_EMAIL` | (you enter it) | Login email of the first admin. Used only on the first start |
| Pixelfed | `ADMIN_PASSWORD` | generated | Password of the first admin. Read it in the service's Variables tab |
| Pixelfed | `APP_KEY` | generated | Laravel encryption key. Never change it after the first start |
| Pixelfed | `APP_DOMAIN` | `${{RAILWAY_PUBLIC_DOMAIN}}` | The instance's domain and federation identity |
| Pixelfed | `PORT` | `8080` | |
| Pixelfed | `DB_HOST`, `DB_PASSWORD`, `REDIS_HOST`, `REDIS_PASSWORD` | references | Private network |
| MySQL | `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD` | generated | Database `pixelfed`, user `pixelfed` |
| Redis | `REDIS_PASSWORD` | generated | |

Optional settings you can add to the Pixelfed service (the start script sets sensible defaults):

- **Email** (password resets, verification): `MAIL_MAILER=smtp`, `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION`, `MAIL_FROM_ADDRESS`. Until then, mail goes to the log.
- **Instance**: `APP_NAME` (default `Pixelfed`), `OPEN_REGISTRATION`, `ENFORCE_EMAIL_VERIFICATION`, `PF_MAX_USERS`, `MAX_PHOTO_SIZE` (KB), `MAX_ALBUM_LENGTH`.
- **Object storage**: `PF_ENABLE_CLOUD=true` with `FILESYSTEM_CLOUD=s3` and the `AWS_*` settings, to keep media in S3-compatible storage instead of the volume.
- **Custom domain**: set `APP_DOMAIN` to it **before** your instance federates. Changing the domain later breaks existing federation links.
- Any other setting from Pixelfed's [`.env.docker.example`](https://github.com/pixelfed/pixelfed/blob/v0.15.2/.env.docker.example).

## Updates

The Dockerfiles pin each image by version and digest. When a new Pixelfed release comes out, this repo bumps the pin and adds a `CHANGELOG.md` entry. Railway then shows an "update available" notice on projects deployed from the template, and you choose when to apply it. Migrations run on the next start. Read `CHANGELOG.md` before you update: breaking changes are listed first.

Back up the MySQL volume before an update (Railway volume backups, or `mysqldump`).

## Local test

```sh
docker build -t pixelfed-railway pixelfed/
```

The template was tested with Docker Compose (MySQL, Redis and Pixelfed built from these folders) and on Railway: first start, admin login, a photo upload and post, and a restart with the data kept.

## License

The wrapper files in this repo are MIT. Pixelfed is AGPL-3.0; MySQL and Redis keep their own licences.
