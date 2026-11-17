# Pixelfed for Railway: the official image, pinned by version and digest.
# Bump both the tag and the digest together, and add a CHANGELOG.md entry.
FROM ghcr.io/pixelfed/pixelfed:v0.15.2@sha256:f1237913ef0d392a5afef1dab8e3dd01234435ea90314a3a7221a2ea00932132

USER root

# Keep a copy of the image's storage/ tree: the Railway volume is mounted over it,
# and the wrapper seeds the volume from this copy on every start (without overwriting).
# An empty .env keeps Pixelfed's web installer (/installer) closed: settings come
# from environment variables, and the installer only opens when no .env exists.
RUN cp -a /var/www/html/storage /opt/pixelfed-storage \
 && install -o www-data -g www-data -m 0640 /dev/null /var/www/html/.env

COPY --chmod=0755 railway-entrypoint.sh railway-start.sh user-count.php /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["/usr/local/bin/railway-start.sh"]
