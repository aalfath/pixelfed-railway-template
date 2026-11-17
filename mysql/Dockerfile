# MySQL 8.4 LTS for Pixelfed, pinned by version and digest.
FROM mysql:8.4.13@sha256:a81d043930e51745522bd5c430961cf8286f0a23f0a9a2a6e0108f7ea71b0902

ENV MYSQL_DATABASE=pixelfed \
    MYSQL_USER=pixelfed

COPY --chmod=0644 railway.cnf /etc/mysql/conf.d/railway.cnf

CMD ["mysqld"]
