# Changelog

## 0.15.2-1 (2026-11-17)

First release of the template.

- Pixelfed v0.15.2 (`ghcr.io/pixelfed/pixelfed:v0.15.2@sha256:f1237913ef0d392a5afef1dab8e3dd01234435ea90314a3a7221a2ea00932132`).
- MySQL 8.4.13 LTS (`mysql:8.4.13@sha256:a81d043930e51745522bd5c430961cf8286f0a23f0a9a2a6e0108f7ea71b0902`), data in `/var/lib/mysql/data`.
- Redis 8.10.3 (`redis:8.10.3-alpine@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3`), append-only file in `/data/redis` (a redis-owned folder on the volume, since Railway volumes are root-owned).
- First admin from `ADMIN_EMAIL` and a generated `ADMIN_PASSWORD`; OAuth keys, instance actor and city list set up on the first start.
- Horizon and the scheduler run inside the Pixelfed service.
